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
	$alert    	  	= 'root@localhost',
  	$emergencyalert = 'emergency@localhost',
	$senderaddr     = "monit@${fqdn}",
	$mailserver     = ['localhost'],

	$http_port      = '2812',
	$http_user      = 'admin',
	$http_secret    = 'cHangeMe',
	$allowips		= ['127.0.0.1'],

	$pool_interval  = 120,
	$start_delay    = 240,
	$mmoniturl      = '',

	$checkpuppet    = true,
) {

	case $::osfamily {
	    'RedHat': {
			exec{"install_monit_5":
			    command => '/usr/bin/rpm  -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/m/monit-5.6-1.el7.x86_64.rpm',
				creates => '/etc/monitrc'
			}

			$monitrc 	= '/etc/monitrc'
			$monitrcreq = Exec["install_monit_5"]
			$monitconf 	= '/etc/monit.d'
	    }
		default: {
			if !defined(Package["monit"]) {
				package { "monit":
					ensure => installed,
				}
			}

			$monitrc 	= '/etc/monit/monitrc'
			$monitrcreq = Package["monit"]
			$monitconf 	= '/etc/monit/conf.d'

		}
	}



	# The service
	service { "monit":
		ensure  => running,
		require => $monitrcreq,
	}

	# How to tell monit to reload its configuration
	exec { "monit reload":
		command     => "/usr/bin/monit reload",
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
	# the "monit" package, but we include it just to be sure.
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
			before  => Service["monit"]
	}

	# The main configuration file
	file { "${monitrc}":
		content => template("monit/monitrc.erb"),
		before  => Service["monit"]
	}

	# system check
	$load1Alarm = $processorcount ? {
		2 => 8,
		3 => 12,
	    4 => 16,
	    5 => 20,
	    6 => 24,
	    7 => 28,
	    8 => 32,
	    default => 4,
	}

  	$load5Alarm = $processorcount ? {
		2 => 24,
		3 => 32,
		4 => 40,
		5 => 48,
		6 => 56,
		7 => 64,
		8 => 72,
    	default => 16,
  }

  	file { "${monitconf}/system.conf":
    	content => template("monit/check_system.erb"),
    	before  => Service["monit"]
  	}

	# Monit is disabled by default on debian / ubuntu
	case $operatingsystem {
		debian, ubuntu: {
			file { "/etc/default/monit":
				content => template("monit/etc_default_monit.erb"),
				before  => Service["monit"]
			}
		}
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
}
