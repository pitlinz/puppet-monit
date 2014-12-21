# Define: monit::check::device
# Creates a monit file check
#
#
# Parameters:
#   namevar     - the name of the device
#   devpath     - path to the device
#   mntpnt      - mount point of the device
#   mntparams   - mount params
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
#   monit::check::device{"routfs":
#     devpath     => "/dev/md0",
#   }
# (end)

define monit::check::device($ensure=present,
                             $devpath=undef,
                             $mntptn=undef,
                             $customlines="") {
  file {"/etc/monit/conf.d/device_$name.conf":
    ensure  => $ensure,
    owner   => "root",
    group   => "root",
    mode    => 0400,
    content => template("monit/check_device.monitrc.erb"),
    notify  => Service["monit"],
  }
}
