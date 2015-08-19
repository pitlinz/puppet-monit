/**
 * predifined monit checks for apache2
 * (c) 2015 by Peter Krebs <pitlinz@sourceforge.net>
 */
define monit::predefined::checkapache(
  $ensure       = present,
  $conffile     = '',
  $pidfile      = false,
  $start        = "/etc/init.d/apache2 start",
  $stop         = "/etc/init.d/apache2 stop",
  $depends_on   = [],
  $customlines  = [],

  $checkhost    = "localhost",
  $checkrequest = '/',

) {

	if $conffile != '' {
		$depends_on_conf = "apacheconf_${name}"
		monit::check::file{$depends_on_conf:
			ensure    => $ensure,
			filepath  => $conffile,
			before    => File["/etc/monit/conf.d/process_apache_${name}.conf"]
		}
	} else {
		$depends_on_conf = false
	}

	$processname = "${name}"

	if $pidfile {
		$apachepidfile = "${pidfile}"
	} elsif $::monit_apache2pid {
   	    $apachepidfile = $::monit_apache2pid
   	} else {
		case $::lsbdistid {
			'Debian': {
				$apachepidfile = "/var/run/apache2.pid"
			}
			'Ubuntu': {
				if $::operatingsystemrelease == "12.04" {
					$apachepidfile = "/var/run/apache2.pid"
				} else {
					$apachepidfile = "/var/run/apache2/apache2.pid"
				}
	    	}
  		}

  	}

	file {"/etc/monit/conf.d/process_apache_${name}.conf":
		ensure  => $ensure,
		owner   => "root",
		group   => "root",
		mode    => "0400",
		content => template("monit/predefined/check_process_apache.monitrc.erb"),
		notify  => Service["monit"],
	}

}
