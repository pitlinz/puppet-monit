# Define: monit::predefined::checksshd
# Creates a monit check for sshd
#
# Parameters:
#   port   		- port used by mysql
# 	checkslave	- ip-address of the slave
# 	mysqlhost	- ip/name of the master
#	mysqluser	- a user with either select or replicate privileges
#	mysqlpwd	- the password
#
# Actions:
#   The following actions gets taken by this defined type:
class monit::predefined::checkmysqld(
	$ensure		= present,
	$port		= "3306",
	$mysqlmaster= '',
	$mysqlslave = '',
	$mysqluser  = '',
	$mysqlpwd   = '',
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

	monit::predefined::checkmysqld::checkconnect{"/etc/monit/scripts/mysql-connect-local.sh":
	    mysqlhost => 'localhost',
	}

	monit::check::programm {"mysqlchkconnect":
		ensure      => $ensure,
		scriptpath  => "/etc/monit/scripts/mysql-connect-local.sh",
		depends_on  => ["mysqld"],
		customlines => ["if status != 0 then alert"],
		#require     => File["/etc/monit/scripts/mysql-connect-local.sh"],
	}


	if $mysqlslave != '' {
		if has_ip_address($mysqlslave) {
			monit::predefined::checkmysqld::checkconnect{"/etc/monit/scripts/mysql-connect-master.sh":
				mysqlhost => $mysqlmaster,
			   	mysqluser => $mysqluser,
				mysqlpwd  => $mysqlpwd
			}

			monit::check::host{"mysqlmaster":
				chkaddress => $mysqlmaster,
			}

			monit::check::programm {"mysqlchkmaster":
				ensure      => $ensure,
				scriptpath  => "/etc/monit/scripts/mysql-connect-local.sh",
				depends_on  => ["mysqlmaster"],
				customlines => ["if status != 0 then alert"],
				#require     => File["/etc/monit/scripts/mysql-connect-local.sh"],
			}


			monit::predefined::checkmysqld::checkslavestate{"/etc/monit/scripts/mysql-slave-state.sh":
			}

			monit::check::programm {"mysqlchkslavestate":
				ensure      => $ensure,
				scriptpath  => "/etc/monit/scripts/mysql-slave-state.sh",
				depends_on  => ["mysqld"],
				customlines => ["if status != 0 then alert"],
			}

		}
	}
}

define monit::predefined::checkmysqld::checkconnect(
    $filename	= $name,
	$mysqlhost	= '',
	$mysqluser  = '',
	$mysqlpwd   = '',
	$chkdb		= 'information_schema',
	$ensure		= present,
) {
  	file { "${filename}":
    	ensure  => $ensure,
    	owner   => "root",
    	group   => "root",
    	mode    => "0555",
    	content => template("monit/checkmysql/mysql-connect.sh.erb"),
  	}
}

define monit::predefined::checkmysqld::checkslavestate(
    $filename	= $name,
	$mysqlhost	= '',
	$mysqluser  = '',
	$mysqlpwd   = '',
	$ensure		= present,
) {
  	file { "${filename}":
    	ensure  => $ensure,
    	owner   => "root",
    	group   => "root",
    	mode    => "0555",
    	content => template("monit/checkmysql/mysql-slavestate.sh.erb"),
  	}
}

