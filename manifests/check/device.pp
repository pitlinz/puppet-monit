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
#   monit::check::device{"rootfs":
#     devpath     => "/dev/md0",
#   }
# (end)

define monit::check::device(
  $ensure             = present,

  $devpath            = false,
  $mntptn             = "",
  $fstype             = "ext4",
  $mntoptions         = "defaults",

  $default_alert      = "root@${::fqdn}",
  $default_usage      = "85%",

  $emergency_alert    = "",
  $emergency_usage    = false,

  $customlines        = [],

  $mismatch_cnt_id    = false, # if you add a number here /sys/block/md<%= mismatch_cnt_id %> is checked


) {
  # notify{"$name: $mntptn at $devpath":}

  if $mntptn != '/' and !empty($mntptn) {
	  case $fstype {
	    'ext4': {
			if !defined(File[$mntptn]) {
				file {"${mntptn}":
			       ensure => directory
				}
			}

	       if !defined(Mount["${mntptn}"]) {
			     mount { "${mntptn}":
			       atboot  => true,
			       ensure  => mounted,
			       device  => "${devpath}",
			       fstype  => "${fstype}",
			       options => "${mntoptions}",
			       dump    => 0,
			       pass    => 2,
			       require => File["${mntptn}"],
			     }
	      }
	    }
	  }
  }

  if $devpath != '' and $mntptn != '' and $fstype != 'nfs' and $fstype != 'lvm' {
	  file {"/etc/monit/conf.d/device_$name.conf":
	    ensure  => $ensure,
	    owner   => "root",
	    group   => "root",
	    mode    => "0440",
	    content => template("monit/check_device.monitrc.erb"),
	    notify  => Service["monit"],
	  }
  }

  if $mismatch_cnt_id {
    if !defined(Monit::Predefined::Checkmdadm["monit_mdadm"]) {
      monit::predefined::checkmdadm{"monit_mdadm":}
    }

    if !defined(File["/etc/monit/scripts/check-mdstat.sh"]) {
		  file { "/etc/monit/scripts/check-mdstat.sh":
		    ensure  => $ensure,
		    owner   => "root",
		    group   => "root",
		    mode    => "0550",
		    content => template("monit/checkscripts/check_mdstat.sh.erb"),
		  }
    }

    if !defined(File["/etc/monit/scripts/check-md-${mismatch_cnt_id}-stat.sh"]) {
      file {"/etc/monit/scripts/check-md-${mismatch_cnt_id}-stat.sh":
	      ensure => link,
	      target => "/etc/monit/scripts/check-mdstat.sh",
	      require => File["/etc/monit/scripts/check-mdstat.sh"],
	      before  => Service["monit"]
	    }
    }

    ::monit::check::programm{"check-md-${mismatch_cnt_id}-stat":
      ensure        => $ensure,
      scriptpath    => "/etc/monit/scripts/check-md-${mismatch_cnt_id}-stat.sh",
      depends_on    => ["mdadm"],
      customlines   => ["if status != 0 then alert"],
      require       => File["/etc/monit/scripts/check-md-${mismatch_cnt_id}-stat.sh"],
    }
  }
}
