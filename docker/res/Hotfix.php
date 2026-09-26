<?php
/**
 * Use this file for hotfixes
 *
 * @file
 */

$wgAutoConfirmAge = 3600;
$wgUnifiedExtensionForFemiwikiBlockByEmail = false;
$wgUnifiedExtensionForFemiwikiRelatedArticlesUseLinks = false;

# Extension:Lockdown
$wgActionLockdown = [
	'history' => [ 'user' ],
	'info' => [ 'user' ],
	'raw' => [ 'user' ],
];
$wgSpecialPageLockdown = [
	'AbuseFilter' => [ 'user' ],
	'Recentchangeslinked' => [ 'user' ],
	'Contributions' => [ 'user' ],
	'Whatlinkshere' => [ 'user' ],
	'Log' => [ 'user' ],
];

foreach ( [
	NS_TALK,
	NS_USER_TALK,
	NS_PROJECT_TALK,
	NS_FILE_TALK,
	NS_MEDIAWIKI_TALK,
	NS_TEMPLATE_TALK,
	NS_HELP_TALK,
	NS_CATEGORY_TALK,
	NS_ITEM_TALK,
	NS_PROPERTY_TALK,
	NS_WIDGET_TALK,
	NS_MODULE_TALK,
	NS_TRANSLATIONS_TALK,
	NS_GADGET_TALK,
	NS_GADGET_DEFINITION_TALK,
	NS_NEWSLETTER_TALK,
	NS_BBS,
	NS_BBS_TALK,
] as $space ) {
	$wgNamespaceContentModels[$space] = CONTENT_MODEL_WIKITEXT;
}

// Maintenance
// 점검이 끝나면 아래 라인 주석처리한 뒤, 아래 문서 내용을 비우면 됨
// https://femiwiki.com/w/%EB%AF%B8%EB%94%94%EC%96%B4%EC%9C%84%ED%82%A4:Sitenotice
$wgReadOnly = '데이터베이스 업그레이드 작업이 진행 중입니다. 작업이 진행되는 동안 사이트 이용이 제한됩니다.';

// 업로드를 막고싶을때엔 아래 라인 주석 해제하면 됨
// $wgEnableUploads = false;

// Nothing in core writes ProfilerExcimer's data to a file. ProfilerOutputDump
// takes ProfilerXhprof only and logs an error for anything else, and
// ProfilerOutputText prints into the response body. Profiler::logData(), the
// path that runs without a request asking for it, calls only outputs whose
// logsToOutput() is false, so a file writer has to be one of those.
// Belongs in the image; it is here so that turning the profiler on is an apply.
class FwProfilerOutputFile extends ProfilerOutput {
	public function canUse() {
		return (bool)( $this->params['outputDir'] ?? '' );
	}

	public function log( array $stats ) {
		$elapsed = microtime( true ) - $_SERVER['REQUEST_TIME_FLOAT'];
		// By CPU rather than wall time: the surplus credit charge is CPU alone
		usort( $stats, static function ( $a, $b ) {
			return $b['cpu'] <=> $a['cpu'];
		} );

		$out = sprintf( "%s %s\nelapsed %.3fs\n\n%-70s %10s %8s %10s %8s\n",
			$_SERVER['REQUEST_METHOD'] ?? '-',
			$_SERVER['REQUEST_URI'] ?? '-',
			$elapsed,
			'name', 'cpu ms', 'cpu %', 'real ms', 'real %'
		);
		foreach ( $stats as $entry ) {
			$out .= sprintf( "%-70s %10.1f %7.1f%% %10.1f %7.1f%%\n",
				$entry['name'], $entry['cpu'], $entry['%cpu'],
				$entry['real'], $entry['%real']
			);
		}

		// Elapsed milliseconds first so that ls puts the worst request last
		file_put_contents(
			sprintf( '%s/%06.0f-%s.txt', $this->params['outputDir'], $elapsed * 1000, uniqid() ),
			$out
		);
	}
}

if ( ( $wgProfiler['class'] ?? null ) === ProfilerExcimer::class ) {
	$wgProfiler['output'] = [ FwProfilerOutputFile::class ];
}
