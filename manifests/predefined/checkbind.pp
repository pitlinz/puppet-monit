# Define: monit::predefined::checksshd
# Creates a monit check for sshd
#
# Parameters:
#   sshport   - port used by sshd
#
# Actions:
#   The following actions gets taken by this defined type:
define monit::predefined::checkbind(
  $ensure=present,
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
    customlines => ["if failed host 127.0.0.1 port 53 type tcp protocol dns then restart",
                    "if failed host 127.0.0.1 port 53 type udp protocol dns then restart",
                    "if 5 restarts within 5 cycles then timeout"]
  }
}
