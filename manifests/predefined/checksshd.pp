# Define: monit::predefined::checksshd
# Creates a monit check for sshd
#
# Parameters:
#   sshport   - port used by sshd
#
# Actions:
#   The following actions gets taken by this defined type:
class monit::predefined::checksshd(
  $ensure   	= present,
  $sshport  	= "22",
  $monitorconf 	= true,
) {

	if $monitorconf == true {
		monit::check::file{"sshd_conf":
	    	filepath => "/etc/ssh/sshd_config",
	    	customlines => ["if failed checksum then alert"],
	  	}
	  	$depends_on  = ["sshd_conf"]
  	} else {
	  	$depends_on  = []
  	}

  	$pidfile     = "/var/run/sshd.pid"
  	$start       = "/etc/init.d/ssh start"
  	$stop        = "/etc/init.d/ssh stop"
  	$customlines = ["if 4 restarts within 6 cycles then timeout"]

  	if !is_array($sshport) {
    	$portlist = [$sshport]
  	} else {
    	$portlist = $sshport
  	}

  	file {"${::monit::monitconf}/process_sshd.conf":
    	ensure  => $ensure,
    	owner   => "root",
    	group   => "root",
    	mode    => "0400",
    	content => template("monit/predefined/check_process_ssh.monitrc.erb"),
    	notify  => Service["monit"],
  	}
}
