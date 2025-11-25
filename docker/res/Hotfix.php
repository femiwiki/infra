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
	'diff' => 'user',
	'history' => 'user',
];
$wgSpecialPageLockdown = [
	'AbuseFilter' => 'user',
	'RecentChangesLinked' => 'user',
	'Contributions' => 'user',
	'WhatLinksHere' => 'user',
	'Logs' => 'user',
];

// FemiwikiCrawlingBlocker
wfLoadExtension( 'FemiwikiCrawlingBlocker' );
$wgFemiwikiCrawlingBlockerEnabled = false;

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
// $wgReadOnly = '데이터베이스 업그레이드 작업이 진행 중입니다. 작업이 진행되는 동안 사이트 이용이 제한됩니다.';

// 업로드를 막고싶을때엔 아래 라인 주석 해제하면 됨
// $wgEnableUploads = false;
