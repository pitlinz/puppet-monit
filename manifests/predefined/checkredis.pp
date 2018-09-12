/**
 * class to check mongodb
 */
class monit::predefined::checkredis(
    $processname = 'redis-server',
    $pidfile	 = '/var/run/redis/redis-server.pid',
	$start		 = "/usr/sbin/service redis-server start",
	$stop		 = "/usr/sbin/service redis-server start",
	$customlines = [
	    "if failed port 6379 then restart",
		"if 3 restarts within 3 cycles then alert"
	],
) {

	monit::check::process{"${processname}":
	    process		=> $processname,
	    pidfile		=> $pidfile,
	    start		=> $start,
	    stop		=> $stop,
		customlines	=> $customlines,
	}

}
