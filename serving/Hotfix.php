<?php
// Emergency settings, loaded after the image's LocalSettings.php; empty otherwise.
// The docker plan loads this with the image's LocalSettings.php, so a broken one fails the plan.

// Protection level for Flow boards being retired. Sysops hold it only while the
// boards are protected; once it is removed from every group nobody can post there.
$wgRestrictionLevels[] = 'flow-archived';
$wgAvailableRights[] = 'flow-archived';
$wgGroupPermissions['sysop']['flow-archived'] = true;
$wgGrantPermissions['protect']['flow-archived'] = true;
