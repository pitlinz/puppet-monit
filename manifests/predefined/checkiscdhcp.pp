# Define: monit::predefined::checkiscdhcp
# Creates a monit check for isc dhcp server
#
# Parameters:
#
# Actions:
#
#
class monit::predefined::checkiscdhcp(
  $ensure		= present,
  $monitorconf 	= true,
  $pidfile		= '',
) {

	if monitorconf == true {
	  	monit::check::file{"dhcpd_conf":
	    	ensure      => $ensure,
	    	filepath => "/etc/dhcp/dhcpd.conf",
	    	customlines => ["if failed checksum then alert"],
	  	}
	  	$dhcpdepends = ["dhcpd_conf","dhcpd_rc"]
  	} else {
  	    file{"/etc/monit/conf.d/file_dhcpd_conf.conf":
  	        ensure => absent,
		}
  	    $dhcpdepends = ["dhcpd_rc"]
  	}

  	monit::check::file{"dhcpd_rc":
    	ensure      => $ensure,
    	filepath => "/etc/init.d/isc-dhcp-server",
    	customlines => [
	    	"if failed checksum then alert",
	    	"if failed permission 755 then unmonitor",
	    	"if failed uid root then unmonitor",
	    	"if failed gid root then unmonitor"
    	]
  	}

  	if $pidfile != '' {
  	    $dhcpdpidfile = $pidfile
  	} else {
		case $::lsbdistid {
		    "Ubuntu": {
		      case $::lsbdistcodename {
		          default: {
		              $dhcpdpidfile = "/var/run/dhcp-server/dhcpd.pid"
		          }
		      }
		    }
			default: {
				$dhcpdpidfile = "/var/run/dhcpd.pid"
			}
		}
	}

  	monit::check::process{"dhcpd":
    	ensure      => $ensure,
    	pidfile     => $dhcpdpidfile,
    	start       => "/etc/init.d/isc-dhcp-server start",
    	stop        => "/etc/init.d/isc-dhcp-server stop",
    	depends_on  => $dhcpdepends,
    	customlines => [
      		"if failed host 127.0.0.1 port 67 type udp then restart",
      		"if 5 restarts within 5 cycles then timeout"
    	],
  	}
}
