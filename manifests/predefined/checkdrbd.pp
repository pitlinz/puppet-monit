# Define: monit::predefined::checkdrbd
# Creates a drbd check for network raid
#
# Parameters:
#
# Actions:
#   The following actions gets taken by this defined type:
#   - create a check for /etc/drbd.conf
#   - create a check script for checking drbd drives
#   - create a check monitoring the script return
#
# Requires:
#   - Package["monit"]
#
class monit::predefined::checkdrbd(
  $ensure=present,
) {

	monit::check::file{"drbd_conf":
    	ensure => $ensure,
    	filepath => "/etc/drbd.conf",
    	customlines => ["if failed checksum then alert"],
  	}

  	file { "/etc/monit/scripts/check-drbd.sh":
    	ensure  => $ensure,
    	owner   => "root",
    	group   => "root",
    	mode    => "0555",
    	content => template("monit/checkscripts/check_drbd.sh.erb"),
  	}

  	monit::check::programm {"drbd_check":
    	ensure      => $ensure,
    	scriptpath  => "/etc/monit/scripts/check-drbd.sh",
    	depends_on  => ["drbd_conf"],
    	customlines => ["if status != 0 then alert"],
  	}


}
