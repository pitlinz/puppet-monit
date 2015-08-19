# Define: monit::check::file
# Creates a monit file check
#
#
# Parameters:
#   namevar     - the name of file
#   filepath    - the filepath
#   start       - the command used by monit to start the service
#   stop        - the command used by monit to stop the service
#   customlines - lets you inject custom lines into the monitrc snippet, just pass an array, and it will appear in the configuration file
#
# Actions:
#   The following actions gets taken by this defined type:
#    - creates /etc/monit/conf.d/namevar.conf as root:root mode 0400 based on _template_
#
# Requires:
#   - Package["monit"]
#
# Sample usage:
# (start code)
#   monit::check::file{"openssh_conf":
#     filepath     => "/etc/sshd/sshd_config",
#     customlines => ["if failed checksum then alert"]
#   }
# (end)

define monit::check::file($ensure=present,
                             $filepath=undef,
                             $start=undef,
                             $start_extras="",
                             $stop=undef,
                             $stop_extras="",
                             $customlines=[]) {
  file {"${::moint::monitconf}/file_$name.conf":
    ensure  => $ensure,
    owner   => "root",
    group   => "root",
    mode    => "0400",
    content => template("monit/check_file.monitrc.erb"),
    notify  => Service["monit"],
  }
}
