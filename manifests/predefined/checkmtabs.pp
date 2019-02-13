/**
 * class monit::predefined::checkmtabs
 *
 * checks all mounted devices
 *
 */
class monit::predefined::checkmtabs(
  	$default_usage      = "90%",
	$emergency_alert    = "",
	$emergency_usage    = false,

	$customlines        = [],
) {

 	$defaults = {
  		ensure   		=> present,
		default_usage 	=> $default_usage,
		emergency_alert	=> $emergency_alert,
		emergency_usage	=> $emergency_usage,
		customlines		=> $customlines
	}

	if !is_string($::monit_curmtab) {
	    notify{'fact monit_curmtab is a string':}
	}

	if is_hash($::monit_curmtab) {
		create_resources(monit::predefined::checkmtab, $::monit_curmtab, $defaults)
	} else {
	    notify{'fact monit_curmtab is not a hash': message => "${::monit_curmtab}",}
	}
}

define monit::predefined::checkmtab(
	$ensure             = present,

	$devpath            = false,
	$mntptn             = "",
	$fstype             = "ext4",
	$mntoptions         = "defaults",
	$dump				= 0,
	$pass				= 2,
	$atboot			  	= false,

  	$default_usage      = "90%",
	$emergency_alert    = "",
	$emergency_usage    = false,

	$customlines        = [],
) {

	monit::check::device{"${name}":
	    ensure			=> $ensure,
	    devpath			=> $devpath,
	    mntptn			=> $mntptn,
	    fstype			=> $fstype,
	    mntoptions		=> $mntoptions,
	    dump			=> $dump,
	    pass			=> $pass,
	    atboot			=> false,

	    default_usage	=> $default_usage,
	    emergency_alert	=> $emergency_alert,
	    emergency_usage	=> $emergency_usage,

	    customlines		=> $customlines,

	}


}
