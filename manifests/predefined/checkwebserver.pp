/**
 * predifined monit checks for apache2
 * (c) 2015 by Peter Krebs <pitlinz@sourceforge.net>
 */
define monit::predefined::checkwebserver(
  $ensure       = present,
  $srvip        = '127.0.0.1',
  $srvname      = ::$fqdn,
  $requestpath  = '/',
  $depends_on   = [],
  $customlines  = [],
) {
    
}
