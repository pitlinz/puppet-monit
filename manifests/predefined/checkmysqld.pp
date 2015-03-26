# Define: monit::predefined::checksshd
# Creates a monit check for sshd
#
# Parameters:
#   sshport   - port used by sshd
#
# Actions:
#   The following actions gets taken by this defined type:
define monit::predefined::checkmysqld(
	$ensure=present,
	$port="3306",
) {

	monit::check::file{"mysqld_conf":
		filepath => "/etc/mysql/my.cnf",
		customlines => ["if failed checksum then alert"],
	}

	monit::check::process{"mysqld":
		pidfile     => "/var/run/mysqld/mysqld.pid",
		start       => "/usr/sbin/service mysql start",
		stop        => "/usr/sbin/service mysql stop",
		depends_on  => ["mysqld_conf"],
		customlines => [
			"if failed port ${port} then restart",
           	"if 2 restarts within 3 cycles then timeout"
       	]
  }

}
