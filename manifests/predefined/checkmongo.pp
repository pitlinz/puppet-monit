/**
 * class to check mongodb
 */
class monit::predefined::checkmongo(
    $processname = 'mongodb',
    $pidfile	 = '/var/run/mongodb/mongodb.pid',
	$start		 = "/usr/sbin/service mongodb start",
	$stop		 = "/usr/sbin/service mongodb start",
	$checkhost	 = "127.0.0.1",
	$checkport	 = "28017",

	$depends_on_conf	= undef,
	$depends_on			= [],
	$customlines		= [],
) {

	file {"/etc/monit/conf.d/process_mongodb.conf":
		owner   => "root",
		group   => "root",
		mode    => "0400",
		content => template("monit/predefined/check_process_mongodb.monitrc.erb"),
		notify  => Service["monit"],
	}
}
