class monit::smartctl(

) {
    package{"smartmontools":
        ensure => latest
	}



}
