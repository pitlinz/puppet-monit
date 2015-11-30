/**
 * control a virsh guest
 */
define monit::predefined::checkvirshguest(
	$ensure	= present,
	$intip	= undef,
) {

	monit::check::file{"virsh_${name}_xml":
		filepath => "/etc/libvirt/qemu/${name}.xml",
		customlines => ["if failed checksum then alert"],
	}

	::monit::check::process{"qemu_${name}":
	    pidfile		=> "/var/run/libvirt/qemu/${name}.pid",
	    start		=> "/usr/bin/virsh start ${name}",
		stop		=> "/usr/bin/virsh stop ${name}",
		depends_on	=> ["virsh_${name}_xml"],
    	customlines => [
			"if 5 restarts within 5 cycles then restart",
		]
	}

	if is_ip_address($intip) {
		::monit::check::host{"virsh_guest_${name}":
		    chkaddress	=> $intip,
	    	start		=> "/usr/bin/virsh start ${name}",
			stop		=> "/usr/bin/virsh destroy ${name}",
		    depends_on	=> ["virsh_${name}_xml","qemu_${name}"],
	    	customlines => [
				"if 5 restarts within 5 cycles then timeout",
			]
		}
	}
}
