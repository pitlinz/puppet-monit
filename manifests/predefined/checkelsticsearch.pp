# Define: monit::predefined::checkelsticsearch
# Creates a monit check for isc dhcp server
#
# Parameters:
#
# Actions:
#
#
class monit::predefined::checkelsticsearch(
  $ensure		= present,
  $pidfile		= '/var/run/elasticsearch/elasticsearch.pid',
  $port			= "9200"
) {

  	monit::check::process{"elasticsearch":
    	ensure      => $ensure,
    	pidfile     => $pidfile,
    	start       => "/etc/init.d/elasticsearch start",
    	stop        => "/etc/init.d/elasticsearch stop",
    	customlines => [
      		"if failed host 127.0.0.1 port $port type tcp then alert",
      		"if failed host 127.0.0.1 port $port type tcp for 3 cycles then restart",
      		"if 5 restarts within 20 cycles then timeout"
    	],
  	}
}
