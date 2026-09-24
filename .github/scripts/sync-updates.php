#!/usr/bin/env php
<?php
// Copy the ```wikitext blocks of the pull requests listed under "Built from:" into the body of a pull request,
// between markers, so post-update.php posts them. A source is copied once, under a marker naming it, and never
// again, so the copies can be edited, or deleted with their marker kept. The docker-mediawiki image bump keeps
// the region when it rewrites the body.
//
// Usage: sync-updates.php OWNER/REPO PR_NUMBER [--dry-run]
// Environment: GH_TOKEN

require __DIR__ . '/updates.php';

const START = '<!-- sync-updates -->';
const END = '<!-- /sync-updates -->';

$dryRun = in_array( '--dry-run', $argv, true );
[ $repo, $number ] = array_values( array_diff( array_slice( $argv, 1 ), [ '--dry-run' ] ) );

$body = str_replace( "\r", '', gh( "repos/$repo/pulls/$number" )['body'] ?? '' );
$pattern = '/\n*' . preg_quote( START, '/' ) . '\n?(.*?)' . preg_quote( END, '/' ) . '\n*/su';
$region = preg_match( $pattern, $body, $m ) ? rtrim( $m[1] ) : '';
$rest = rtrim( preg_replace( $pattern, "\n", $body ) );
if ( !preg_match( '/^Built from:\h*$/mu', $rest ) ) {
	echo "$repo#$number: no \"Built from:\" list, nothing to copy\n";
	exit;
}
preg_match_all( '/^- ([\w.-]+\/[\w.-]+#\d+)\h*$/mu', $rest, $refs );
$added = 0;
foreach ( $refs[1] as $ref ) {
	$marker = "<!-- from $ref -->";
	if ( str_contains( $region, $marker ) ) {
		continue;
	}
	[ $source, $n ] = explode( '#', $ref );
	$blocks = blocks( gh( "repos/$source/pulls/$n" )['body'] ?? '' );
	// A source with no block yet is left for a later run
	if ( $blocks ) {
		$copies = array_map( fn ( $block ) => "```wikitext\n$block\n```", $blocks );
		$region = ltrim( "$region\n\n$marker\n" . implode( "\n\n", $copies ) );
		$added++;
	}
}
if ( !$added ) {
	echo "$repo#$number: nothing new to copy\n";
	exit;
}
$synced = "$rest\n\n" . START . "\n$region\n" . END . "\n";
if ( $dryRun ) {
	echo $synced;
	exit;
}
$file = tempnam( sys_get_temp_dir(), 'body' );
file_put_contents( $file, $synced );
passthru( 'gh api --silent -X PATCH ' . escapeshellarg( "repos/$repo/pulls/$number" ) . ' -F body=@' . escapeshellarg( $file ), $status );
unlink( $file );
if ( $status !== 0 ) {
	fail( "could not update $repo#$number" );
}
echo "$repo#$number: copied the blocks of $added pull request(s)\n";
