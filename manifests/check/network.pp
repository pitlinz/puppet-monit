# Define: monit::check::network
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

define monit::check::network(
    $ensure         = present,
    $interface      = 'eth0',
    $address        = undef,
    $depends_on     = [],
    $saturation     = "90%",
    $customlines    = [
                "if download > 100 MB/s then alert",
                "if total uploaded > 1 GB in last hour then alert"
        ],
    $mgroups        = [],
) {
        include monit

        file {"${::monit::monitconf}/net_$name.conf":
            ensure  => $ensure,
            owner   => "root",
            group   => "root",
            mode    => "0400",
            content => template("monit/check_network.monitrc.erb"),
            notify  => Service["monit"],
        }
}
