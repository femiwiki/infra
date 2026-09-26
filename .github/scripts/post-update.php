#!/usr/bin/env php
<?php
// Post the ```wikitext blocks of an applied pull request to 페미위키:업데이트, under the minute of the apply within its
// day, after any merged docker pull request whose own post failed, under the minute it merged.
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

/** A block one heading level down, since it goes under a time that is itself under a day */
function demote( string $block ): string {
	return preg_replace( '/^(=+)([^=].*?)(=+)\h*$/mu', '=$1$2$3=', $block );
}

/**
 * The page with the post under its day, a ==day== that the table of contents shows, holding a ===time=== per
 * apply, newest first. A day without one gets it above the first section of that day or earlier, an older
 * ==day time== section included
 */
function insert( string $text, DateTimeInterface $at, string $link, array $blocks ): string {
	$day = $at->format( 'n월 j일' );
	$time = $at->format( 'H:i' );
	$post = "===$time===\n\n$link\n\n" . implode( "\n\n", $blocks ) . "\n\n";
	$sections = preg_split( '/^(?===[^=])/mu', $text );
	for ( $i = str_starts_with( $text, '==' ) ? 0 : 1; $i < count( $sections ); $i++ ) {
		if ( !preg_match( '/^==\s*(\d+)월\s*(\d+)일(\s+\d+:\d+)?\s*==/u', $sections[$i], $m )
			|| sprintf( '%02d%02d', $m[1], $m[2] ) > $at->format( 'md' )
		) {
			continue;
		}
		if ( sprintf( '%02d%02d', $m[1], $m[2] ) === $at->format( 'md' ) && empty( $m[3] ) ) {
			$posts = preg_split( '/^(?====[^=])/mu', $sections[$i] );
			for ( $j = 1; $j < count( $posts ); $j++ ) {
				if ( preg_match( '/^===\s*(\d+):(\d+)\s*===/u', $posts[$j], $t ) && sprintf( '%02d%02d', $t[1], $t[2] ) <= $at->format( 'Hi' ) ) {
					break;
				}
			}
			array_splice( $posts, $j, 0, $post );
			$sections[$i] = implode( '', $posts );
			return implode( '', $sections );
		}
		break;
	}
	array_splice( $sections, $i, 0, "==$day==\n\n$post" );
	return implode( '', $sections );
}

/** The page with the PR linked under the heading of the post, or of the older section, that a post from before the link put its block in */
function linkUnder( string $text, string $block, string $link ): string {
	preg_match_all( '/^(?:==[^=].*==|===\s*\d+:\d+\s*===)\h*\n\n?/mu', substr( $text, 0, strpos( $text, $block ) ), $headings, PREG_OFFSET_CAPTURE );
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

/** The current text and timestamp of a year's page */
function page( string $title ): array {
	$page = wiki( [
		'action' => 'query', 'prop' => 'revisions', 'rvprop' => 'content|timestamp', 'rvslots' => 'main', 'titles' => $title,
	] )['query']['pages'][0];
	$revision = $page['revisions'][0] ?? [];
	return [ $revision['slots']['main']['content'] ?? '', $revision['timestamp'] ?? '' ];
}

function title( DateTimeInterface $at ): string {
	return '페미위키:업데이트/' . $at->format( 'Y' ) . '년';
}

function seoul( string $time ): DateTime {
	return ( new DateTime( $time, new DateTimeZone( 'Asia/Seoul' ) ) )->setTimezone( new DateTimeZone( 'Asia/Seoul' ) );
}

/** Whether a pull request changes the workspace whose apply posts the notes */
function appliesDocker( string $repo, int $number ): bool {
	foreach ( gh( "repos/$repo/pulls/$number/files?per_page=100" ) as $file ) {
		if ( str_starts_with( $file['filename'], 'docker/' ) ) {
			return true;
		}
	}
	return false;
}

/**
 * The merged pull requests whose note a failed post left off the page: merged after the newest one the page links,
 * carrying a block, and changing docker/, oldest first
 */
function missed( string $repo, int $current, string $text ): array {
	if ( !preg_match( '/^https:\/\/github\.com\/' . preg_quote( $repo, '/' ) . '\/pull\/(\d+)$/m', $text, $m ) ) {
		return [];
	}
	$since = gh( "repos/$repo/pulls/$m[1]" )['merged_at'] ?? null;
	if ( !$since ) {
		return [];
	}
	$query = urlencode( "repo:$repo is:pr is:merged merged:>$since" );
	$found = [];
	foreach ( gh( "search/issues?q=$query&per_page=100" )['items'] as $item ) {
		$number = $item['number'];
		if ( $number === $current || preg_match( "/^https:\/\/github\.com\/" . preg_quote( $repo, '/' ) . "\/pull\/$number$/m", $text ) ) {
			continue;
		}
		$pr = gh( "repos/$repo/pulls/$number" );
		if ( blocks( $pr['body'] ?? '' ) && appliesDocker( $repo, $number ) ) {
			$found[$pr['merged_at']] = $number;
		}
	}
	ksort( $found );
	return array_values( $found );
}

/** Post one pull request's blocks under the given minute, or say why not */
function post( string $repo, int $number, DateTime $at, bool $dryRun ): void {
	$pr = gh( "repos/$repo/pulls/$number" );
	$blocks = blocks( $pr['body'] ?? '' );
	if ( !$blocks ) {
		echo "$repo#$number: no ```wikitext block, nothing to post\n";
		return;
	}
	$title = title( $at );
	[ $text, $timestamp ] = page( $title );
	// A re-run of the apply lands under a later minute, so a PR whose link already heads a section is not posted
	// again: its blocks may since have been translated, so they are not what tells
	$link = "https://github.com/$repo/pull/$number";
	// A block is on the page as posted, a level down, or as posted before days grouped the posts
	$onPage = fn ( $block ) => str_contains( $text, demote( $block ) ) ? demote( $block ) : ( str_contains( $text, $block ) ? $block : null );
	$new = array_values( array_map( 'demote', array_filter( $blocks, fn ( $block ) => $onPage( $block ) === null ) ) );
	// The summary links to the day, since a summary does not link a URL or a repo#number and a time repeats daily
	if ( preg_match( '/^' . preg_quote( $link, '/' ) . '$/m', $text ) ) {
		echo "$title: $repo#$number already posted\n";
		return;
	} elseif ( $new ) {
		$merged = insert( $text, $at, $link, $new );
		$summary = '/* ' . sectionOf( $merged, $new[0] ) . ' */ 배포된 변경 사항 추가';
	} else {
		$merged = linkUnder( $text, $onPage( $blocks[0] ), $link );
		$summary = '/* ' . sectionOf( $merged, $onPage( $blocks[0] ) ) . ' */ 배포 풀 리퀘스트 링크 추가';
	}
	if ( $dryRun ) {
		$before = tempnam( sys_get_temp_dir(), 'page' );
		$after = tempnam( sys_get_temp_dir(), 'page' );
		file_put_contents( $before, $text );
		file_put_contents( $after, $merged );
		echo "$repo#$number summary: $summary\n";
		passthru( "diff -u $before $after" );
		unlink( $before );
		unlink( $after );
		return;
	}
	$edit = wiki( [
		'action' => 'edit', 'title' => $title, 'text' => $merged, 'summary' => $summary, 'bot' => 1,
		'basetimestamp' => $timestamp, 'token' => csrf(),
	] )['edit'];
	echo "$title: $repo#$number $edit[result] rev " . ( $edit['newrevid'] ?? '?' ) . "\n";
}

function csrf(): string {
	static $token = null;
	if ( $token === null ) {
		$login = wiki( [
			'action' => 'login', 'lgname' => getenv( 'WIKI_DEPLOY_BOT_USER' ), 'lgpassword' => getenv( 'WIKI_DEPLOY_BOT_PASSWORD' ),
			'lgtoken' => wiki( [ 'action' => 'query', 'meta' => 'tokens', 'type' => 'login' ] )['query']['tokens']['logintoken'],
		] )['login'];
		if ( $login['result'] !== 'Success' ) {
			fail( 'login: ' . json_encode( $login ) );
		}
		$token = wiki( [ 'action' => 'query', 'meta' => 'tokens' ] )['query']['tokens']['csrftoken'];
	}
	return $token;
}

$dryRun = in_array( '--dry-run', $argv, true );
[ $repo, $number ] = array_values( array_diff( array_slice( $argv, 1 ), [ '--dry-run' ] ) );
$number = (int)$number;
if ( !$dryRun && ( !getenv( 'WIKI_DEPLOY_BOT_USER' ) || !getenv( 'WIKI_DEPLOY_BOT_PASSWORD' ) ) ) {
	echo "no bot account to log in with, nothing to post\n";
	exit;
}

$appliedAt = getenv( 'APPLIED_AT' );
if ( $appliedAt === '' ) {
	$appliedAt = gh( "repos/$repo/pulls/$number" )['merged_at'] ?? fail( "$repo#$number has not merged, so give APPLIED_AT" );
}
$at = seoul( $appliedAt ?: 'now' );

// A post that failed, say while an apply had the wiki read-only, left its note off the page; this one carries it
[ $text ] = page( title( $at ) );
$missed = missed( $repo, $number, $text );
if ( $missed ) {
	echo '::warning::posting notes an earlier apply failed to post: ' . implode( ', ', array_map( fn ( $n ) => "#$n", $missed ) ) . "\n";
}
foreach ( $missed as $late ) {
	post( $repo, $late, seoul( gh( "repos/$repo/pulls/$late" )['merged_at'] ), $dryRun );
}
post( $repo, $number, $at, $dryRun );
