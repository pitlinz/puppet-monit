# Define: monit::check::host
# Creates a monit host check
#
#
# Parameters:
#   namevar     - the name of file
#   chkaddress  - the ip address of the host
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


define monit::check::host($ensure=present,
                             $chkaddress=undef,
                             $start=undef,
                             $start_extras="",
                             $stop=undef,
                             $stop_extras="",
                             $depends_on=[],
                             $customlines=""
) {
	include monit

  	file {"${::monit::monitconf}/host_$name.conf":
	    ensure  => $ensure,
	    owner   => "root",
	    group   => "root",
	    mode    => 0400,
	    content => template("monit/check_host.monitrc.erb"),
	    notify  => Service["monit"],
	}
}
