#!/usr/bin/env php
<?php
// Post the ```wikitext blocks of an applied pull request to 페미위키:업데이트, under the minute of the apply.
//
// Usage: post-update.php OWNER/REPO PR_NUMBER [--dry-run]
// Environment: GH_TOKEN, WIKI_DEPLOY_BOT_USER, WIKI_DEPLOY_BOT_PASSWORD (the last two not needed with --dry-run)

const WIKI_API = 'https://femiwiki.com/api.php';

function fail( string $message ): never {
	fwrite( STDERR, "$message\n" );
	exit( 1 );
}

function gh( string $path ): array {
	$json = shell_exec( 'gh api ' . escapeshellarg( $path ) );
	return json_decode( $json ?? '', true ) ?? fail( "gh api $path failed" );
}

/** The contents of the ```wikitext fenced blocks of a PR body */
function blocks( string $body ): array {
	preg_match_all( '/^```wikitext\h*\n(.*?)^```\h*$/msu', str_replace( "\r", '', $body ), $found );
	return array_values( array_filter( array_map( 'trim', $found[1] ), 'strlen' ) );
}

/** The page with a new section inserted above the first existing one */
function prepend( string $text, string $heading, array $blocks ): string {
	$sections = preg_split( '/^(?===[^=])/mu', $text );
	$lead = str_starts_with( $text, '==' ) ? 0 : 1;
	array_splice( $sections, $lead, 0, "==$heading==\n\n" . implode( "\n\n", $blocks ) . "\n\n" );
	return implode( '', $sections );
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

$blocks = blocks( gh( "repos/$repo/pulls/$number" )['body'] ?? '' );
if ( !$blocks ) {
	echo "$repo#$number: no ```wikitext block, nothing to post\n";
	exit;
}
if ( !$dryRun && ( !getenv( 'WIKI_DEPLOY_BOT_USER' ) || !getenv( 'WIKI_DEPLOY_BOT_PASSWORD' ) ) ) {
	echo "no bot account to log in with, nothing to post\n";
	exit;
}

$now = new DateTime( 'now', new DateTimeZone( 'Asia/Seoul' ) );
$title = '페미위키:업데이트/' . $now->format( 'Y' ) . '년';
$page = wiki( [
	'action' => 'query', 'prop' => 'revisions', 'rvprop' => 'content|timestamp', 'rvslots' => 'main', 'titles' => $title,
] )['query']['pages'][0];
$revision = $page['revisions'][0] ?? [];
$text = $revision['slots']['main']['content'] ?? '';
// A re-run of the apply lands under a later minute, so a block already on the page is not posted again
$blocks = array_values( array_filter( $blocks, fn ( $block ) => !str_contains( $text, $block ) ) );
if ( !$blocks ) {
	echo "$title: already posted\n";
	exit;
}
$merged = prepend( $text, $now->format( 'n월 j일 H:i' ), $blocks );
if ( $dryRun ) {
	$before = tempnam( sys_get_temp_dir(), 'page' );
	$after = tempnam( sys_get_temp_dir(), 'page' );
	file_put_contents( $before, $text );
	file_put_contents( $after, $merged );
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
	'action' => 'edit', 'title' => $title, 'text' => $merged, 'summary' => "$repo#$number", 'bot' => 1,
	'basetimestamp' => $revision['timestamp'] ?? '', 'token' => $token,
] )['edit'];
echo "$title: $edit[result] rev " . ( $edit['newrevid'] ?? '?' ) . "\n";
