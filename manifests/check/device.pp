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

define monit::check::device(  
  $ensure             = present,
  
  $devpath            = false,
  $mntptn             = $name,
  $fstype             = "ext4",
  $mntoptions         = "defaults",
      
  $default_alert      = "",
  $default_usage      = "85%",

  $emergency_alert    = "${default_alert}",
  $emergency_usage    = "95%",
 
  $customlines        = [],
  
  $mismatch_cnt_id    = false, # if you add a number here /sys/block/md<%= mismatch_cnt_id %> is checked
  
  
) {
  if $mntptn != '/' and $mntptn != '' {
	  if !defined(File[$mntptn]) {
	    file {"${mntptn}":
	       ensure => directory
	    }
	  }
  
	  case $fstype {    
	    'ext4': {
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
      
  file {"/etc/monit/conf.d/device_$name.conf":
    ensure  => $ensure,
    owner   => "root",
    group   => "root",
    mode    => "0440",
    content => template("monit/check_device.monitrc.erb"),
    notify  => Service["monit"],
  }
  
  if $mismatch_cnt_id {
    if !defined(File["/etc/monit/scripts/check-mdstat.sh"]) {    
		  file { "/etc/monit/scripts/check-mdstat.sh":
		    ensure  => $ensure,
		    owner   => "root",
		    group   => "root",
		    mode    => 0555,
		    content => template("monit/checkscripts/check_mdstat.sh.erb"),
		  }    
    }
    
    ::monit::check::programm{"md${mismatch_cnt_id}_mismatch_cnt":
      ensure  => $ensure,
      scriptpath  => "/etc/monit/scripts/check-mdstat.sh",
      depends_on  => ["mdadm"],
      customlines => ["if status != 0 then alert"],
      require     => File["/etc/monit/scripts/check-mdstat.sh"],
    } 
  }
}
