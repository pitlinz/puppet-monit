# Define: monit::predefined::checkbind
# Creates a monit check for bind
#
# Parameters:
#   listenip    - the ip on which bind is listen
#   listenport  - the port on which bind is listen
#
# Actions:
#   The following actions gets taken by this defined type:
#
#
define monit::predefined::checkbind(
  $ensure     = present,
  $listenip   = '127.0.0.1',
  $listenport = '53'
) {

  monit::check::file{"named_conf":
    ensure      => $ensure,
    filepath => "/etc/bind/named.conf",
    customlines => ["if failed checksum then alert"],
  }

  monit::check::file{"named_rc":
    ensure      => $ensure,
    filepath => "/etc/init.d/bind9",
    customlines => [
      "if failed checksum then alert",
      "if failed permission 755 then unmonitor",
      "if failed uid root then unmonitor",
      "if failed gid root then unmonitor"
    ]
  }

  monit::check::process{"named":
    ensure      => $ensure,
    pidfile     => "/var/run/named/named.pid",
    start       => "/etc/init.d/bind9 start",
    stop        => "/etc/init.d/bind9 stop",
    depends_on  => ["named_conf","named_rc"],
    customlines => ["if failed host ${listenip} port ${listenport} type tcp protocol dns then restart",
                    "if failed host ${listenip} port ${listenport} type udp protocol dns then restart",
                    "if 5 restarts within 5 cycles then timeout"]
  }
}
