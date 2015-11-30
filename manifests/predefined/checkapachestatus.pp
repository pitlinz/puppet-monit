/**
 * configure apache_status
 *
 * @see http://mmonit.com/wiki/Monit/MonitorApacheStatus
 */
class monit::predefined::checkapachestatus (
  	$priority		= 99,
	$monitchecks   	= [
	    "if failed host status.apache port 80 protocol apache-status dnslimit > 25% then alert",
	    "if failed host status.apache port 80 protocol apache-status loglimit > 80% then alert",
	    "if failed host status.apache port 80 protocol apache-status waitlimit < 20% then alert",
	    "if cpu > 80% for 5 cycles then alert",
	    "if cpu > 95% for 10 cycles then restart",
	    "if totalmem > 10000.0 MB for 10 cycles then alert",
	    "if totalmem > 16000.0 MB for 20 cycles then restart",
	    "if children > 1000 then restart",
	    "if loadavg(5min) greater than 10 for 5 cycles then restart",
	    "if loadavg(15min) greater than 15 for 15 cycles then restart",
	    "if 30 restarts within 60 cycles then timeout",
	]
) {
    include monit

	host {"status.apache":
	    ensure  => present,
	    ip      => "127.0.0.1"
	}

	file {"/var/www/apachestatus/":
		ensure => directory,
		owner  => "www-data",
		group  => "www-data",
		mode   => "0550",
		require => Package["apache2"]
  	}

	file {"/var/www/apachestatus/index.html":
		ensure  => present,
		mode    => "0444",
		content => "<html><head><title>apachestatus</title></heady><body><h1>It works</h1></body></html>\n",
		require => File["/var/www/apachestatus/"]
	}

	::monit::predefined::checkapache {"apache_status":
		conffiles    => ["/etc/apache2/sites-enabled/${priority}-status.apache.conf"],
		checkhost   => "status.apache",
		before      => Service["monit"],
		customlines => $monitchecks
	}
}

