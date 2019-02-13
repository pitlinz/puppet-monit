/**
 * checks a mysql database via scrpt
 *
 */
define monit::check::script_mysqldb(
    $ensure		= present,
    $scriptpath = '/etc/monit/scripts/',
    $scriptpre	= 'mysql',
	$mysqlhost	= '',
	$mysqluser  = '',
	$mysqlpwd   = '',
	$chkdb		= 'information_schema',
	$mgroups	= [],
) {
    $_basename 	= "${scriptpre}-${mysqlhost}-${mysqluser}-${chkdb}.sh"
    $_filename 	= "${scriptpath}${_basename}"

  	file { "${_filename}":
    	ensure  => $ensure,
    	owner   => "root",
    	group   => "root",
    	mode    => "0555",
    	content => template("monit/checkmysql/mysql-connect.sh.erb"),
  	}

  	monit::check::programm{"${_basename}":
		ensure      => $ensure,
		scriptpath  => "${_filename}",
		customlines => ["if status != 0 then alert"],
		require     => File["${_filename}"],
		mgroups		=> $mgroups
	}
}
