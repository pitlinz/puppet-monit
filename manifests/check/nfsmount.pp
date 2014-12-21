# Define: monit::check::nfsmount
#
# Creates a monit nfs check
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


define monit::check::host(
  $ensure=present,
  ) {

  }
