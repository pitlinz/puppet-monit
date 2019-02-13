# Module: monit
#
# A puppet module to configure the monit service, and add definitions to be
# used from other classes and modules.
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
# Micah Anderson micah@riseup.net
#
# To set any of the following, simply set them as variables in your manifests
# before the class is included, for example:
#
# forged by Peter Krebs <pitlinz@sourceforge.net>
#
class monit(
    $version        = '5.25.2',
    $dwnlpqath      = 'https://bitbucket.org/tildeslash/monit/downloads/',

    $alert          = 'root@localhost',
    $emergencyalert = 'emergency@localhost',
    $senderaddr     = "monit@${::fqdn}",
    $mailserver     = ['localhost'],

    $http_port      = '2812',
    $http_user      = 'admin',
    $http_secret    = 'cHangeMe',
    $allowips       = ['127.0.0.1'],

    $pool_interval  = 60,
    $start_delay    = 120,
    $mmoniturl      = '',

    $checkpuppet    = true,

    $memoryusage    = '90%',
    $swapusage      = '50%',
    $cpu_user       = '90%',
    $cpu_system     = '70%',
    $cpu_wait       = '80%'
) {

  if !defined(Package['wget']) {
    package{'wget':
      ensure => latest
    }
  }

  case $::operatingsystem {
    'debian','ubuntu': {
      case $::architecture {
        'amd64': {
          $_dwnlurl = "${dwnlpqath}monit-${version}-linux-x64.tar.gz"
        }
        default: {
          $_dwnlurl = "${dwnlpqath}monit-${version}.tar.gz"
        }
      }

      $monitrc    = '/etc/monit/monitrc'
      $monitrcreq = Package['wget']
      $monitconf  = '/etc/monit/conf.d'

      package{'monit':
          ensure => absent,
          before => File['/etc/init.d/monit']
      }
    }

    default: {
      $_dwnlurl   = "${dwnlpqath}monit-${version}.tar.gz"
      $monitrc    = '/etc/monit/monitrc'
      $monitrcreq = Exec["wget_${_dwnlurl}"]
      $monitconf  = '/etc/monit/conf.d'
    }
  }

    if !defined(File['/usr/src/downloads']) {
        file{'/usr/src/downloads':
            ensure => directory,
            mode   => '0755'
        }
    }

    $_dwnltarget = "/usr/src/downloads/monit-${version}.tar.gz"

    exec{"wget_${_dwnlurl}":
        command => "/usr/bin/wget -O ${_dwnltarget} ${_dwnlurl}",
        creates => "/usr/local/bin/monit.${version}",
        require => [File['/usr/src/downloads'],Package['wget']],
        notify  => Exec["untar_${_dwnltarget}"]
    }

    exec{"untar_${_dwnltarget}":
        command     => "/bin/tar -xzf ${_dwnltarget}",
        cwd         => '/usr/src/downloads',
        refreshonly => true,
        notify      => Exec["cp_${_dwnltarget}","cp_${_dwnltarget}_man"]
    }

    exec{"cp_${_dwnltarget}":
        command     => "/bin/cp /usr/src/downloads/monit-${version}/bin/monit /usr/local/bin/monit.${version};",
        refreshonly => true,
        notify      => [File['/usr/local/bin/monit'],Service['monit'],Exec["rm_${_dwnltarget}"]],
    }

    file {'/usr/local/bin/monit':
        ensure      => link,
        target      => "/usr/local/bin/monit.${version}",
        require     => Exec["cp_${_dwnltarget}"]
    }

    exec{"cp_${_dwnltarget}_man":
        command     => "/bin/cp /usr/src/downloads/monit-${version}/man/man1/*  /usr/share/man/man1/",
        refreshonly => true,
        notify      => Exec["rm_${_dwnltarget}"]
    }

    exec{"rm_${_dwnltarget}":
        command     => "/bin/rm -Rf /usr/src/downloads/monit-${version}",
        refreshonly => true,
        require     => Exec["cp_${_dwnltarget}_man","cp_${_dwnltarget}"]
    }


    file {'/etc/init.d/monit':
        content => template('monit/init_monit.erb'),
        before  => Service['monit'],
        mode    => '0555',
        notify 	=> Exec['update-rc_monit']
    }


    if $::lsbdistcodename == 'precise' {
        file{"/etc/rc${::runlevel}.d/S99monit":
            ensure => link,
            target => '/etc/init.d/monit',
            before => Service['monit'],
        }
    }

    exec{'update-rc_monit':
        command => '/usr/sbin/update-rc.d monit defaults 90',
        creates => '/etc/rc5.d/S05monit',
        before  	=> Service['monit'],
        refreshonly	=> true,
        #unless		=> '/bin/ls /etc/rc5.d/S0* | /bin/grep -c monit'
    }

    if ($::lsbdistid == 'Ubuntu') and ((0.0 + $::operatingsystemrelease) > 16.04) {
        file {'/lib/systemd/system/monit.service':
            ensure => present,
            content => template('monit/systemd.monit.service.erb'),
            notify  => Exec['systemctl enable monit']
        }

        exec {'systemctl enable monit':
            command => '/bin/systemctl enable monit',
            refreshonly => true
        }
    }

    exec {'monit_lo_input':
        command => '/sbin/iptables -A INPUT -i lo -p tcp --dport 2812 -j ACCEPT',
        unless  => '/sbin/iptables -L INPUT -nv | /bin/grep lo | /bin/grep 2812 | /bin/grep ACCEPT'
    }

    # $monit_start	= '/etc/init.d/monit start'
    # $monit_restart	= '/etc/init.d/monit restart'
    # $monit_stop	    = '/etc/init.d/monit stop'

    # The service
    service { 'monit':
        ensure  => running,
        require => $monitrcreq,
        # start	=> $monit_start,
        # restart	=> $monit_restart,
        # stop	=> $monit_stop
    }

    # How to tell monit to reload its configuration
    exec { 'monit reload':
        command     => '/usr/local/bin/monit reload',
        refreshonly => true,
    }

    # Default values for all file resources
    File {
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
        notify  => Exec['monit reload'],
        require => $monitrcreq,
    }


    # The main configuration directory, this should have been provided by
    # the 'monit' package, but we include it just to be sure.
    file { '/etc/monit':
            ensure  => directory,
            mode    => '0700',
    }

    # The configuration snippet directory.  Other packages can put
    # *.conf files into this directory, and monit will include them.
    file { $monitconf:
            ensure  => directory,
            mode    => '0700',
            require => $monitrcreq,
            before  => Service['monit']
    }

    # The main configuration file
    file { $monitrc:
        content => template('monit/monitrc.erb'),
        before  => Service['monit']
    }

    file{ '/usr/local/etc/monitrc':
        ensure => link,
        target	=> $monitrc
    }


    # system check

    $load1alarm = $::processorcount + 1
    $load5alarm	= $::processorcount * 2 + 2

    file { "${monitconf}/system.conf":
        ensure => present,
        content => template('monit/check_system.monitrc.erb'),
        before  => Service['monit']
    }

    file { '/etc/monit/scripts/':
        ensure => 'directory',
        mode    => '0755',
    }

    file { '/var/lib/monit/':
        ensure => 'directory',
        mode    => '0755',
    }

    file { '/var/lib/monit/events':
        ensure => 'directory',
        mode    => '0755',
    }

    if $checkpuppet {
        case $puppetversion {
            /^2.*/: {
                $puppetpidfile = '/var/puppet/run/agent.pid'
            }
            default: {
                $puppetpidfile = '/var/run/puppet/agent.pid'
            }
        }

        monit::check::process{'puppet':
            pidfile => $puppetpidfile,
            start  =>  '/etc/init.d/puppet start',
            stop   =>  '/etc/init.d/puppet stop'
        }
    }

    file {"${monitconf}/process_puppet_agent.conf":
        ensure => absent
    }

    if ('localhost' in $mailserver) {
        if !defined(Package['postfix']) {
            package{'postfix': ensure => latest}
        }

        if !defined(Service['postfix']) {
            service{'postfix':
                ensure => 'running',
                require	=> Package['postfix']
            }
        }
    }
}
