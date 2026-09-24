<?php
// What post-update.php and sync-updates.php share.

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
