/**
 * class to check tomcat
 */
class monit::predefined::checktomcat(
    $processname = 'tomcat7',
    $pidfile	 = '/var/run/tomcat7.pid',
	$start		 = "/usr/sbin/service tomcat7 start",
	$stop		 = "/usr/sbin/service tomcat7 stop",
	$checkhost	 = "127.0.0.1",
	$checkport	 = "8080",

	$depends_on_conf	= undef,
	$depends_on			= [],
	$customlines		= [],
) {

	file {"/etc/monit/conf.d/process_tomcat.conf":
		owner   => "root",
		group   => "root",
		mode    => "0400",
		content => template("monit/predefined/check_process_mongodb.monitrc.erb"),
		notify  => Service["monit"],
	}
}
