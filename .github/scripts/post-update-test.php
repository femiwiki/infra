#!/usr/bin/env php
<?php
// post-update.php against a read-only stub wiki and a stub gh has to fail where the run shows it

$dir = sys_get_temp_dir() . '/post-update-test-' . getmypid();
mkdir( "$dir/bin", 0777, true );

file_put_contents( "$dir/bin/gh", <<<'PHP'
#!/usr/bin/env php
<?php
echo json_encode( [ 'body' => "```wikitext\n===fix===\n* 무엇이 고쳐짐\n```", 'merged_at' => '2026-10-14T12:00:00Z' ] );
PHP );
chmod( "$dir/bin/gh", 0755 );

file_put_contents( "$dir/wiki.php", <<<'PHP'
<?php
header( 'Content-Type: application/json' );
echo json_encode( match ( $_POST['action'] ) {
	'login' => [ 'login' => [ 'result' => 'Success' ] ],
	'edit' => [ 'error' => [ 'code' => 'readonly', 'info' => 'The wiki is currently in read-only mode.' ] ],
	default => [ 'query' => [
		'tokens' => [ 'logintoken' => '+\\', 'csrftoken' => '+\\' ],
		'pages' => [ [ 'missing' => true ] ],
	] ],
} );
PHP );

$port = 18000 + getmypid() % 1000;
// The stub wiki and the script run as processes of their own, like on the run
// phpcs:ignore MediaWiki.Usage.ForbiddenFunctions.proc_open
$server = proc_open( [ PHP_BINARY, '-S', "127.0.0.1:$port", "$dir/wiki.php" ],
	[ [ 'pipe', 'r' ], [ 'file', '/dev/null', 'w' ], [ 'file', '/dev/null', 'w' ] ], $pipes );
// phpcs:ignore Generic.PHP.NoSilencedErrors.Discouraged -- refused until the server listens
for ( $i = 0; $i < 50 && !@fsockopen( '127.0.0.1', $port ); $i++ ) {
	usleep( 100000 );
}

$summary = "$dir/summary.md";
$env = [
	'PATH' => "$dir/bin:" . getenv( 'PATH' ),
	'WIKI_API' => "http://127.0.0.1:$port/",
	'WIKI_DEPLOY_BOT_USER' => 'bot',
	'WIKI_DEPLOY_BOT_PASSWORD' => 'password',
	'APPLIED_AT' => '2026-10-14 21:00',
	'GITHUB_ACTIONS' => 'true',
	'GITHUB_SERVER_URL' => 'https://github.com',
	'GITHUB_STEP_SUMMARY' => $summary,
];
// phpcs:ignore MediaWiki.Usage.ForbiddenFunctions.proc_open
$run = proc_open( [ PHP_BINARY, __DIR__ . '/post-update.php', 'femiwiki/infra', '1095' ],
	[ [ 'pipe', 'r' ], [ 'pipe', 'w' ], [ 'pipe', 'w' ] ], $pipes, null, $env );
$stdout = stream_get_contents( $pipes[1] );
$stderr = stream_get_contents( $pipes[2] );
$status = proc_close( $run );
proc_terminate( $server );

$checks = [
	'exits 1' => $status === 1,
	'annotates the run' => str_contains( $stdout, '::error::the update note of #1095 was not posted: '
		. "http://127.0.0.1:$port/: The wiki is currently in read-only mode.\n" ),
	'says how to post it again' => str_contains( is_file( $summary ) ? file_get_contents( $summary ) : '',
		'run [post update](https://github.com/femiwiki/infra/actions/workflows/post-update.yml) with `pr` 1095.' ),
];
array_map( 'unlink', [ "$dir/bin/gh", "$dir/wiki.php", ...glob( "$dir/summary.md" ) ] );
rmdir( "$dir/bin" );
rmdir( $dir );

foreach ( $checks as $name => $ok ) {
	echo ( $ok ? 'ok' : 'not ok' ) . " - $name\n";
}
if ( in_array( false, $checks, true ) ) {
	echo "stdout:\n$stdout\nstderr:\n$stderr";
	exit( 1 );
}
