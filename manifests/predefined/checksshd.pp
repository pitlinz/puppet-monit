# Define: monit::predefined::checksshd
# Creates a monit check for sshd
#
# Parameters:
#   sshport   - port used by sshd
#
# Actions:
#   The following actions gets taken by this defined type:
define monit::predefined::checksshd(
  $ensure=present,
  $sshport="22",
) {

  monit::check::file{"sshd_conf":
    filepath => "/etc/ssh/sshd_config",
    customlines => ["if failed checksum then alert"],
  }

  monit::check::process{"sshd":
    pidfile     => "/var/run/sshd.pid",
    start       => "/etc/init.d/ssh start",
    stop        => "/etc/init.d/ssh stop",
    depends_on  => ["sshd_conf"],
    customlines => ["if failed port ${sshport} then restart",
                    "if 2 restarts within 3 cycles then timeout"]
  }

}
