# Define: monit::predefined::checkmdadm
# Creates a monit check for software raid
#
# Parameters:
#   warnlimit   - max number of md mismatch_cnt before warn
#   critilimit  - max number of md mismatch_cnt before alert
#
# Actions:
#   The following actions gets taken by this defined type:
#   - create a check for /etc/mdadm/mdadm.conf
#   - create a check for mdadm process
#   - create a check script for mismatch_cnt
#   - create a check monitoring the script return
#
# Requires:
#   - Package["monit"]
#
class monit::predefined::checkmdadm(
	$ensure       =present,
	$warnlimit    =1,
	$critlimit    =5,
	$run_cnt_chk  = true, # runs mismatch_cnt script with param *
) {

    include monit

	monit::check::file{"mdadm_conf":
		ensure => $ensure,
		filepath => "/etc/mdadm/mdadm.conf",
		customlines => ["if failed checksum then alert"],
	}

	monit::check::process{"mdadm":
		ensure => $ensure,
		pidfile => "/var/run/mdadm/monitor.pid",
		depends_on => ["mdadm_conf"],
		customlines => ["if 2 restarts within 4 cycles then timeout"],
	}

	if $run_cnt_chk {
		if !defined(File["/etc/monit/scripts/check-mdstat.sh"]) {
			file { "/etc/monit/scripts/check-mdstat.sh":
				ensure  => $ensure,
				owner   => "root",
				group   => "root",
				mode    => '0555',
				content => template("monit/checkscripts/check_mdstat.sh.erb"),
			}
		}

		monit::check::programm {"mdadm_check":
			ensure      => $ensure,
			scriptpath  => "/etc/monit/scripts/check-mdstat.sh",
			depends_on  => ["mdadm"],
			customlines => ["if status != 0 then alert"],
			require     => File["/etc/monit/scripts/check-mdstat.sh"],
		}
  	}

	if !defined(File["/etc/monit/scripts/check_mdresyncdelay.sh"]) {
		file { "/etc/monit/scripts/check_mdresyncdelay.sh":
			ensure  => $ensure,
			owner   => "root",
			group   => "root",
			mode    => '0555',
			content => template("monit/checkscripts/check_mdresyncdelay.sh.erb"),
		}
	}

	monit::check::programm {"mdadm_checkresync":
		ensure      => $ensure,
		scriptpath  => "/etc/monit/scripts/check_mdresyncdelay.sh",
		depends_on  => ["mdadm"],
		customlines => ["if status != 0 then alert"],
		require     => File["/etc/monit/scripts/check_mdresyncdelay.sh"],
	}

	if !defined(File["/etc/monit/scripts/check_mdup.sh"]) {
		file { "/etc/monit/scripts/check_mdup.sh":
			ensure  => $ensure,
			owner   => "root",
			group   => "root",
			mode    => '0555',
			content => template("monit/checkscripts/check_mdup.sh.erb"),
		}
	}

	monit::check::programm {"mdadm_checkup":
		ensure      => $ensure,
		scriptpath  => "/etc/monit/scripts/check_mdup.sh",
		depends_on  => ["mdadm"],
		customlines => ["if status != 0 then alert"],
		require     => File["/etc/monit/scripts/check_mdup.sh"],
	}

}
