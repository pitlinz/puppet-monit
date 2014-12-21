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
# The following is a list of the currently available variables:
#
# monit_alert:                who should get the email notifications?
#                             Default: root@localhost
#
# monit_enable_httpd:         should the httpd daemon be enabled?
#                             set this to 'yes' to enable it, be sure
#                             you have set the $monit_default_secret
#                             Valid values: yes or no
#                             Default: no
#
# monit_httpd_port:           what port should the httpd run on?
#                             Default: 2812
#
#
# monit_mailserver:           where should monit be sending mail?
#                             set this to the mailserver
#                             Default: localhost
#
# monit_pool_interval:        how often (in seconds) should monit poll?
#                             Default: 120
#

class monit {

  notice( "checking monit for : $fqdn" )

	# The monit_secret is used with the fqdn of the host to make a
	# password for the monit http server.
	$monit_default_secret="This is not very secret, is it?"

	# The default alert recipient.  You can override this by setting the
	# variable "$monit_alert" in your node specification.
	$monit_default_alert="root@localhost"

  # How often should the daemon pool? Interval in seconds.
  case $monit_pool_interval {
    '': { $monit_pool_interval = '60' }
  }

  # Should the httpd daemon be enabled, or not? By default it is not
  case $monit_enable_httpd {
    '': { $monit_enable_httpd = 'no' }
  }

	# The package
	package { "monit":
		ensure => installed,
	}

	# The service
	service { "monit":
		ensure  => running,
		require => Package["monit"],
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
		mode    => 0400,
		notify  => Exec["monit reload"],
		require => Package["monit"],
	}

	# The main configuration directory, this should have been provided by
	# the "monit" package, but we include it just to be sure.
	file { "/etc/monit":
			ensure  => directory,
			mode    => 0700,
	}

	# The configuration snippet directory.  Other packages can put
	# *.conf files into this directory, and monit will include them.
	file { "/etc/monit/conf.d":
			ensure  => directory,
			mode    => 0700,
	}

	# The main configuration file
	file { "/etc/monit/monitrc":
    owner   => "root",
    group   => "root",
    mode    => 0400,
		content => template("monit/monitrc.erb"),
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
    2 => 16,
    3 => 24,
    4 => 32,
    5 => 40,
    6 => 48,
    7 => 56,
    8 => 64,
    default => 8,
  }

  file { "/etc/monit/conf.d/system.conf":
    content => template("monit/check_system.erb"),
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
    owner   => "root",
    group   => "root",
    mode    => 0755,
  }

  file { "/var/lib/monit/":
    ensure => "directory",
    owner   => "root",
    group   => "root",
    mode    => 0755,
  }

}
