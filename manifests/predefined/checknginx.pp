/**
 * predifined monit checks for apache2
 * (c) 2015 by Peter Krebs <pitlinz@sourceforge.net>
 */
class monit::predefined::checknginx(
  $ensure       = present,
  $conffiles    = [],
  $depends_on   = [],
  $customlines  = [],

  $checkhost    = "localhost",

) {

    if is_array($customlines) {
		$_customlines = concat([
      		"if failed host 127.0.0.1 port 80 type tcp then alert",
      		"if failed host 127.0.0.1 port 80 type tcp for 3 cycles then restart",
      		"if 5 restarts within 20 cycles then timeout"
		],$customlines)
    } else {
		$_customlines = [
      		"if failed host 127.0.0.1 port 80 type tcp then alert",
      		"if failed host 127.0.0.1 port 80 type tcp for 3 cycles then restart",
      		"if 5 restarts within 20 cycles then timeout"
		]

    }

  	monit::check::process{"nginx":
    	ensure      => $ensure,
    	pidfile     => "/var/run/nginx.pid",
    	start       => "/etc/init.d/nginx start",
    	stop        => "/etc/init.d/nginx start",
    	customlines => $_customlines,
    	notify		=> Service["monit"],
    	require		=> Package["monit"],
  	}

  	file{"/etc/nginx/sites-available/status.localhost.conf":
  	    content		=> template("monit/predefined/nginx_status.conf.erb"),
  	    require		=> Package["nginx"],
  	    notify		=> Service["nginx"],
  	}

  	file{"/etc/nginx/sites-enabled/999-status.localhost.conf":
		ensure		=> link,
		target		=> "/etc/nginx/sites-available/status.localhost.conf",
		require		=> File["/etc/nginx/sites-available/status.localhost.conf"],
		notify		=> Service["nginx"]
	}

}
