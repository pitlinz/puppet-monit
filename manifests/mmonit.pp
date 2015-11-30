/**
 * class to install mmonit
 */
class monit::mmonit(
    $version 		= "3.5.1",
    $licenseowner 	= "Tildeslash Ltd. - Trial License",
	$licensekey		= "NROZWCEXMG-G5BYJCSZMM-P7EVOOJULX-EOPCOQBO7H-E2QXGUCT7P CMTU5QZMXT-5PLKXKEHEW-5UKOEPMBAE-Y4RNNGYBTK-3GDW4WAFI2 T56T35Q7GZ-E6GNMWR6NA-ODCOQ4NMYT-D3TL5ECKRO-LCTDC5EQPG OC2YATZ52B-LI6YYP5KRU-77XJQJYO7N-TFGCC3WLJV-2M3VY2FNQC P2M24"
) {

	$dwnlfile = "mmonit-${version}-linux-x64.tar.gz"
    $dwnlpath = "https://mmonit.com/dist"

	if !defined(File["/usr/src/downloads"]) {
	    file{"/usr/src/downloads":
	        ensure => directory
	    }
	}

	exec{"wget_mmonit_${version}":
	    command => "/usr/bin/wget ${dwnlpath}/${dwnlfile}",
	    cwd		=> "/usr/src/downloads",
		require	=> File["/usr/src/downloads"],
		creates	=> "/usr/src/downloads/${dwnlfile}",
	}

	exec{"untar_mmonit_${version}":
	    command => "/bin/tar -xzf /usr/src/downloads/${dwnlfile}",
	    cwd		=> "/opt",
		require	=> Exec["wget_mmonit_${version}"],
		creates	=> "/opt/mmonit-3.5.1",
	}

	file{"/opt/mmonit":
	    ensure 	=> link,
	    target 	=> "/opt/mmonit-3.5.1",
		require	=> Exec["untar_mmonit_${version}"],
	}

	file{"/etc/init.d/mmonit":
	    mode 	=> "0550",
		content => template("monit/mmonit/init_mmonit.erb"),
		require	=> File["/opt/mmonit"],
		notify	=> Exec["update-rc_mmonit"],
	}

	exec{"update-rc_mmonit":
	    command => "/usr/sbin/update-rc.d mmonit defaults 90",
	    refreshonly => true,
	}

	service{"mmonit":
		ensure => running,
		require	=> [File["/opt/mmonit"],Exec["untar_mmonit_${version}"]],
	}

	file{"/opt/mmonit/conf/server.xml":
		content => template("monit/mmonit/server.xml.erb"),
		require	=> [File["/opt/mmonit","/etc/init.d/mmonit"],Exec["untar_mmonit_${version}"]],
		notify	=> Service["mmonit"],
	}

}
