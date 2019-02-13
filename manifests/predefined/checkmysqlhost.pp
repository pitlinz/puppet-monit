/**
 * check a mysql host
 */
class monit::predefined::checkmysqlhost (
    $ensure		= present,
	$mysqlhost	= '',
	$mysqluser  = '',
	$mysqlpwd   = '',
	$chkdb		= 'information_schema',
) {

}
