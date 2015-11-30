/**
 * check vsftpd
 */
class monit::predefined::checkvsftpd(
    $processname = 'vsftpd',
    $pidfile	 = '',
	$start		 = "/usr/sbin/service vsftpd start",
	$stop		 = "/usr/sbin/service vsftpd stop",
	$customlines = [
	    "if failed port 21 protocol ftp then restart",
		"if 3 restarts within 3 cycles then alert"
	]
) {
	monit::check::process{"${processname}":
	    process		=> $processname,
	    pidfile		=> $pidfile,
	    start		=> $start,
	    stop		=> $stop,
		customlines	=> $customlines,
	}
}
