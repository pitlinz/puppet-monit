# Define: monit::check::programm
# Creates a monit programm check,
#
# Parameters:
#   namevar       - the name check
#   scriptpath    - path to the file
#   scriptparams  - params to pass to the script
#   start         - the command used by monit to start the service
#   stop          - the command used by monit to stop the service
#   customlines   - lets you inject custom lines into the monitrc snippet, just pass an array, and it will appear in the configuration file


define monit::check::programm(
		  $ensure       = present,
		  $scriptpath   = "",
		  $scriptparams = "",
		  $start="",
		  $start_extras="",
		  $stop="",
		  $stop_extras="",
		  $depends_on=[],
		  $customlines=""
  ) {

  file {"${::moint::monitconf}/programm_$name.conf":
    ensure  => $ensure,
    owner   => "root",
    group   => "root",
    mode    => 0400,
    content => template("monit/check_programm.monitrc.erb"),
    notify  => Service["monit"],
  }


}
