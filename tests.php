<?php
$apc_avail = function_exists('apc_store');

if (!$apc_avail) {
	echo 'in memory caching is not available, this will cause lots of problems'."\r\n";
	exit(1);
}

$cache_enabled = true;
$random = md5(time());
$ckey = 'r_test';
$timeout = 30;
apc_store($ckey, $random, $timeout);

$cached = apc_fetch($ckey,$success);

if ($cached != $random) {
	echo 'in memory caching is not *working*, this will cause lots of problems'."\r\n";
	exit(1);
}

exit(0);
