# Define: monit::predefined::checkpostfix
# Creates a monit check for postfix mail server
#
# Parameters:
#
# Actions:
#
#
define monit::predefined::checkpostfix(
  $ensure=present,
) {

  monit::check::file{"postfix_master_conf":
    ensure      => $ensure,
    filepath => "/etc/postfix/master.cf",
    customlines => ["if failed checksum then alert"],
  }

  monit::check::file{"postfix_main_conf":
    ensure      => $ensure,
    filepath => "/etc/postfix/main.cf",
    customlines => ["if failed checksum then alert"],
  }


  monit::check::file{"postfix_rc":
    ensure      => $ensure,
    filepath => "/etc/init.d/postfix",
    customlines => [
      "if failed checksum then alert",
      "if failed permission 755 then unmonitor",
      "if failed uid root then unmonitor",
      "if failed gid root then unmonitor"
    ]
  }

  monit::check::process{"postfix":
    ensure      => $ensure,
    pidfile     => "/var/spool/postfix/pid/master.pid",
    start       => "/etc/init.d/postfix start",
    stop        => "/etc/init.d/postfix stop",
    depends_on  => ["postfix_master_conf","postfix_main_conf"],
    customlines => [
      "if failed host 127.0.0.1 port 25 protocol smtp then restart",
      "if 5 restarts within 5 cycles then timeout"
    ]
  }
}
