#!/usr/bin/env php
<?php
// Post the ```wikitext blocks of an applied pull request to 페미위키:업데이트, under the minute of the apply.
//
// Usage: post-update.php OWNER/REPO PR_NUMBER [--dry-run]
// Environment: GH_TOKEN, WIKI_DEPLOY_BOT_USER, WIKI_DEPLOY_BOT_PASSWORD (the last two not needed with --dry-run),
// and APPLIED_AT to head a late post with an earlier time: a time in Asia/Seoul, or empty for when the PR merged

const WIKI_API = 'https://femiwiki.com/api.php';

function fail( string $message ): never {
	fwrite( STDERR, "$message\n" );
	exit( 1 );
}

function gh( string $path ): array {
	$json = shell_exec( 'gh api ' . escapeshellarg( $path ) );
	return json_decode( $json ?? '', true ) ?? fail( "gh api $path failed" );
}

/** The contents of the ```wikitext fenced blocks of a PR body, the example in a comment aside */
function blocks( string $body ): array {
	$body = preg_replace( '/<!--.*?-->/su', '', str_replace( "\r", '', $body ) );
	preg_match_all( '/^```wikitext\h*\n(.*?)^```\h*$/msu', $body, $found );
	return array_values( array_filter( array_map( 'trim', $found[1] ), 'strlen' ) );
}

/** The page with a new section above the first one headed no later than it, a day without a time counting as its midnight */
function insert( string $text, DateTimeInterface $at, string $link, array $blocks ): string {
	$sections = preg_split( '/^(?===[^=])/mu', $text );
	$key = $at->format( 'mdHi' );
	for ( $i = str_starts_with( $text, '==' ) ? 0 : 1; $i < count( $sections ); $i++ ) {
		if ( preg_match( '/^==\s*(\d+)월\s*(\d+)일(?:\s+(\d+):(\d+))?\s*==/u', $sections[$i], $m )
			&& sprintf( '%02d%02d%02d%02d', $m[1], $m[2], $m[3] ?? 0, $m[4] ?? 0 ) <= $key
		) {
			break;
		}
	}
	array_splice( $sections, $i, 0, '==' . $at->format( 'n월 j일 H:i' ) . "==\n\n$link\n\n" . implode( "\n\n", $blocks ) . "\n\n" );
	return implode( '', $sections );
}

/** The page with the PR linked under the heading of the section a post from before the link put its block in */
function linkUnder( string $text, string $block, string $link ): string {
	preg_match_all( '/^==[^=].*==\h*\n\n?/mu', substr( $text, 0, strpos( $text, $block ) ), $headings, PREG_OFFSET_CAPTURE );
	[ $heading, $offset ] = end( $headings[0] ) ?: fail( 'no section heads the posted block' );
	return substr_replace( $text, "$link\n\n", $offset + strlen( $heading ), 0 );
}

/** The name of the section a block sits in, for an edit summary that links to it */
function sectionOf( string $text, string $block ): string {
	preg_match_all( '/^==([^=].*?)==\h*$/mu', substr( $text, 0, strpos( $text, $block ) ), $headings );
	return trim( end( $headings[1] ) ?: fail( 'no section heads the posted block' ) );
}

function wiki( array $params ): array {
	static $ch = null;
	$ch ??= curl_init();
	curl_setopt_array( $ch, [
		CURLOPT_URL => WIKI_API,
		CURLOPT_POST => true,
		CURLOPT_RETURNTRANSFER => true,
		CURLOPT_COOKIEFILE => '',
		CURLOPT_USERAGENT => 'femiwiki/infra post-update',
		CURLOPT_POSTFIELDS => http_build_query( $params + [ 'format' => 'json', 'formatversion' => 2 ] ),
	] );
	$result = json_decode( curl_exec( $ch ) ?: fail( WIKI_API . ': ' . curl_error( $ch ) ), true );
	if ( isset( $result['error'] ) ) {
		fail( WIKI_API . ': ' . $result['error']['info'] );
	}
	return $result;
}

$dryRun = in_array( '--dry-run', $argv, true );
[ $repo, $number ] = array_values( array_diff( array_slice( $argv, 1 ), [ '--dry-run' ] ) );

$pr = gh( "repos/$repo/pulls/$number" );
$blocks = blocks( $pr['body'] ?? '' );
if ( !$blocks ) {
	echo "$repo#$number: no ```wikitext block, nothing to post\n";
	exit;
}
if ( !$dryRun && ( !getenv( 'WIKI_DEPLOY_BOT_USER' ) || !getenv( 'WIKI_DEPLOY_BOT_PASSWORD' ) ) ) {
	echo "no bot account to log in with, nothing to post\n";
	exit;
}

$appliedAt = getenv( 'APPLIED_AT' );
if ( $appliedAt === '' ) {
	$appliedAt = $pr['merged_at'] ?? fail( "$repo#$number has not merged, so give APPLIED_AT" );
}
$at = ( new DateTime( $appliedAt ?: 'now', new DateTimeZone( 'Asia/Seoul' ) ) )->setTimezone( new DateTimeZone( 'Asia/Seoul' ) );
$title = '페미위키:업데이트/' . $at->format( 'Y' ) . '년';
$page = wiki( [
	'action' => 'query', 'prop' => 'revisions', 'rvprop' => 'content|timestamp', 'rvslots' => 'main', 'titles' => $title,
] )['query']['pages'][0];
$revision = $page['revisions'][0] ?? [];
$text = $revision['slots']['main']['content'] ?? '';
// A re-run of the apply lands under a later minute, so a PR whose link already heads a section is not posted
// again: its blocks may since have been translated, so they are not what tells
$link = "https://github.com/$repo/pull/$number";
$new = array_values( array_filter( $blocks, fn ( $block ) => !str_contains( $text, $block ) ) );
// The summary links to the section, since a summary does not link a URL or a repo#number
if ( preg_match( '/^' . preg_quote( $link, '/' ) . '$/m', $text ) ) {
	echo "$title: already posted\n";
	exit;
} elseif ( $new ) {
	$merged = insert( $text, $at, $link, $new );
	$summary = '/* ' . sectionOf( $merged, $new[0] ) . ' */ 배포된 변경 사항 추가';
} else {
	$merged = linkUnder( $text, $blocks[0], $link );
	$summary = '/* ' . sectionOf( $merged, $blocks[0] ) . ' */ 배포 풀 리퀘스트 링크 추가';
}
if ( $dryRun ) {
	$before = tempnam( sys_get_temp_dir(), 'page' );
	$after = tempnam( sys_get_temp_dir(), 'page' );
	file_put_contents( $before, $text );
	file_put_contents( $after, $merged );
	echo "summary: $summary\n";
	passthru( "diff -u $before $after" );
	unlink( $before );
	unlink( $after );
	exit;
}

$token = wiki( [ 'action' => 'query', 'meta' => 'tokens', 'type' => 'login' ] )['query']['tokens']['logintoken'];
$login = wiki( [
	'action' => 'login', 'lgname' => getenv( 'WIKI_DEPLOY_BOT_USER' ), 'lgpassword' => getenv( 'WIKI_DEPLOY_BOT_PASSWORD' ), 'lgtoken' => $token,
] )['login'];
if ( $login['result'] !== 'Success' ) {
	fail( 'login: ' . json_encode( $login ) );
}
$token = wiki( [ 'action' => 'query', 'meta' => 'tokens' ] )['query']['tokens']['csrftoken'];
$edit = wiki( [
	'action' => 'edit', 'title' => $title, 'text' => $merged, 'summary' => $summary, 'bot' => 1,
	'basetimestamp' => $revision['timestamp'] ?? '', 'token' => $token,
] )['edit'];
echo "$title: $edit[result] rev " . ( $edit['newrevid'] ?? '?' ) . "\n";
