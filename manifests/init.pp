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
# $monit_enable_httpd = yes
# $monit_httpd_port = 8888
# $monit_secret="something secret, something safe"
# $monit_alert="someone@example.org"
# $monit_mailserver="mail.example.org"
# $monit_pool_interval="120"
#
# include monit
#

class monit(
    $version        = '5.25.1',
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

    $syswait        = 80,
    $memoryusage    = '90%'
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
                    $_dwnlurl = $_dwnlurl = "${dwnlpqath}monit-${version}.tar.gz"
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
        creates => $_dwnltarget,
        require => [File['/usr/src/downloads'],Package['wget']],
        notify  => Exec["untar_${_dwnltarget}"]
    }

    exec{"untar_${_dwnltarget}":
        command     => "/bin/tar -xzf ${_dwnltarget}",
        cwd         => '/usr/src/downloads',
        refreshonly => true,
        notify      => Exec["cp_${_dwnltarget}"]
    }

    exec{"cp_${_dwnltarget}":
        command     => "/bin/cp /usr/src/downloads/monit-${version}/bin/* /usr/local/bin/",
        refreshonly => true,
        notify      => Service['monit']
    }


    file {'/etc/init.d/monit':
        content => template('monit/init_monit.erb'),
        before  => Service['monit'],
        mode    => '0555',
        #notify 	=> Exec["update-rc_monit"]
    }


    if $::lsbdistcodename == 'precise' {
        file{"/etc/rc${::runlevel}.d/S99monit":
            ensure => link,
            target => '/etc/init.d/monit',
            before => Service['monit'],
        }
    } elsif $::runlevel == 5 {
        exec{'update-rc_monit':
            command => "/usr/sbin/update-rc.d monit defaults 90",
            creates => "/etc/rc5.d/S05monit",
            before  	=> Service['monit'],
    #		    refreshonly	=> true,
            unless		=> "/bin/ls /etc/rc5.d/S0* | /bin/grep -c monit"
        }
    }

    # The service
    service { 'monit':
        ensure  => running,
        require => $monitrcreq,
        start	=> "/etc/init.d/monit start",
        restart	=> "/etc/init.d/monit restart",
        stop	=> "/etc/init.d/monit stop"
    }

    # How to tell monit to reload its configuration
    exec { "monit reload":
        command     => "/usr/local/bin/monit reload",
        refreshonly => true,
    }

    # Default values for all file resources
    File {
        owner   => "root",
        group   => "root",
        mode    => "0400",
        notify  => Exec["monit reload"],
        require => $monitrcreq,
    }


    # The main configuration directory, this should have been provided by
    # the 'monit' package, but we include it just to be sure.
    file { "/etc/monit":
            ensure  => directory,
            mode    => "0700",
    }

    # The configuration snippet directory.  Other packages can put
    # *.conf files into this directory, and monit will include them.
    file { "${monitconf}":
            ensure  => directory,
            mode    => "0700",
            require => $monitrcreq,
            before  => Service['monit']
    }

    # The main configuration file
    file { "${monitrc}":
        content => template("monit/monitrc.erb"),
        before  => Service['monit']
    }

    file{ "/usr/local/etc/monitrc":
        ensure => link,
        target	=> $monitrc
    }


    # system check

    $load1Alarm = $::processorcount + 1
    $load5Alarm	= $::processorcount * 2 + 2

    file { "${monitconf}/system.conf":
        content => template("monit/check_system.erb"),
        before  => Service['monit']
    }

    file { "/etc/monit/scripts/":
        ensure => "directory",
        mode    => "0755",
    }

    file { "/var/lib/monit/":
        ensure => "directory",
        mode    => "0755",
    }

    file { "/var/lib/monit/events":
        ensure => "directory",
        mode    => "0755",
    }

    if $checkpuppet {
        case $puppetversion {
            /^2.*/: {
                $puppetpidfile = "/var/puppet/run/agent.pid"
            }
            default: {
                $puppetpidfile = "/var/run/puppet/agent.pid"
            }
        }

        monit::check::process{"puppet":
            pidfile => $puppetpidfile,
            start  =>  "/etc/init.d/puppet start",
            stop   =>  "/etc/init.d/puppet stop"
        }
    }

    file {"${monitconf}/process_puppet_agent.conf":
        ensure => absent
    }

    if ('localhost' in $mailserver) {
        if !defined(Package["postfix"]) {
            package{"postfix": ensure => latest}
        }

        if !defined(Service["postfix"]) {
            service{"postfix":
                ensure => "running",
                require	=> Package["postfix"]
            }
        }
    }
}
