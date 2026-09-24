#!/usr/bin/env php
<?php
// Post the `## 업데이트` lines of an applied pull request to 페미위키:업데이트.
//
// Usage: post-update.php OWNER/REPO PR_NUMBER [--dry-run]
// Environment: GH_TOKEN, WIKI_DEPLOY_BOT_USER, WIKI_DEPLOY_BOT_PASSWORD (the last two not needed with --dry-run)

const KINDS = [ '추가', '변경', '수정' ];
const WIKI_API = 'https://femiwiki.com/api.php';

function fail( string $message ): never {
	fwrite( STDERR, "$message\n" );
	exit( 1 );
}

function gh( string $path ): array {
	$json = shell_exec( 'gh api ' . escapeshellarg( $path ) );
	return json_decode( $json ?? '', true ) ?? fail( "gh api $path failed" );
}

/** [ [kind, sentence], ... ] from the `## 업데이트` section of a PR body */
function items( string $body ): array {
	$body = str_replace( "\r", '', $body );
	if ( !preg_match( '/^##\s*업데이트\s*$(.*?)(?=^##\s|\z)/msu', $body, $section ) ) {
		return [];
	}
	preg_match_all( '/^\h*(?:[-*]\h*)?(추가|변경|수정)\h*:\h*(\S.*?)\h*$/mu', $section[1], $found, PREG_SET_ORDER );
	return array_map( fn ( $f ) => [ $f[1], $f[2] ], $found );
}

/** Non-empty lines of a chunk of wikitext, without its first line */
function lines( string $chunk ): array {
	return array_values( array_filter( array_slice( explode( "\n", rtrim( $chunk ) ), 1 ), 'strlen' ) );
}

/**
 * The day's section rebuilt as heading, lines under no level-3 heading, the 추가/변경/수정 blocks
 * with the new lines appended, then any other level-3 headings verbatim.
 */
function rebuild( string $section, string $day, array $new ): string {
	$blocks = preg_split( '/^(?====)/mu', $section );
	$existing = [ '' => lines( array_shift( $blocks ) ) ];
	$tail = '';
	foreach ( $blocks as $block ) {
		if ( $tail === '' && preg_match( '/^===\s*(추가|변경|수정)\s*===/u', $block, $m ) ) {
			$existing[$m[1]] = lines( $block );
		} else {
			$tail .= $block;
		}
	}
	$out = "==$day==\n\n";
	if ( $existing[''] ) {
		$out .= implode( "\n", $existing[''] ) . "\n\n";
	}
	foreach ( KINDS as $kind ) {
		$body = $existing[$kind] ?? [];
		foreach ( $new[$kind] ?? [] as $line ) {
			if ( !in_array( $line, $body, true ) ) {
				$body[] = $line;
			}
		}
		if ( $body ) {
			$out .= "===$kind===\n\n" . implode( "\n", $body ) . "\n\n";
		}
	}
	return $out . $tail;
}

/** The page with the day's section rebuilt, or created on top when absent */
function merge( string $text, string $day, array $new ): string {
	$sections = preg_split( '/^(?===[^=])/mu', $text );
	foreach ( $sections as $i => $section ) {
		if ( preg_match( '/^==\s*' . preg_quote( $day, '/' ) . '\s*==\s*$/mu', $section ) ) {
			$sections[$i] = rebuild( $section, $day, $new );
			return implode( '', $sections );
		}
	}
	$lead = str_starts_with( $text, '==' ) ? 0 : 1;
	array_splice( $sections, $lead, 0, rebuild( '', $day, $new ) );
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

$pr = gh( "repos/$repo/pulls/$number" );
$sources = [ $pr ];
preg_match_all( '/^- ([\w.-]+\/[\w.-]+)#(\d+)\s*$/mu', $pr['body'] ?? '', $refs, PREG_SET_ORDER );
foreach ( $refs as $ref ) {
	$sources[] = gh( "repos/$ref[1]/pulls/$ref[2]" );
}
$new = [];
foreach ( $sources as $source ) {
	foreach ( items( $source['body'] ?? '' ) as [ $kind, $sentence ] ) {
		$new[$kind][] = "*$sentence [$source[html_url]]";
	}
}
if ( !$new ) {
	echo "$repo#$number: no `## 업데이트` lines, nothing to post\n";
	exit;
}
if ( !$dryRun && ( !getenv( 'WIKI_DEPLOY_BOT_USER' ) || !getenv( 'WIKI_DEPLOY_BOT_PASSWORD' ) ) ) {
	echo "no bot account to log in with, nothing to post\n";
	exit;
}

$now = new DateTime( 'now', new DateTimeZone( 'Asia/Seoul' ) );
$title = '페미위키:업데이트/' . $now->format( 'Y' ) . '년';
$day = $now->format( 'n' ) . '월 ' . $now->format( 'j' ) . '일';
$page = wiki( [
	'action' => 'query', 'prop' => 'revisions', 'rvprop' => 'content|timestamp', 'rvslots' => 'main', 'titles' => $title,
] )['query']['pages'][0];
$revision = $page['revisions'][0] ?? [];
$text = $revision['slots']['main']['content'] ?? '';
$merged = merge( $text, $day, $new );
if ( $merged === $text ) {
	echo "$title: already posted\n";
	exit;
}
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
