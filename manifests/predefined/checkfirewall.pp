# Define: monit::predefined::firewall
# Creates a check if firewall rules are applied
#
# Parameters:
#
# Requires:
#   - Package["monit"]
#
class monit::predefined::checkfirewall(
  $ensure=present,
) {
  	monit::check::programm {"firewall_check":
    	ensure      => $ensure,
    	scriptpath  => "/etc/init.d/firewall status",
    	start		=> "/etc/init.d/firewall start",
		stop		=> "/etc/init.d/firewall stop",
    	customlines => [
    		"if status != 0 then restart",
    		"if 5 restarts within 5 cycles then timeout",
    	],
  	}

}
