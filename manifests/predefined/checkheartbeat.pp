/**
 * crates a monit check for heartbeat
 *
 *
 */
class monit::predefined::checkheartbeat(
    $ensure = present,
) {
	monit::check::file{"ha_authkeys":
		filepath => "/etc/ha.d/authkeys",
		customlines => [
			"if failed checksum then alert",
			"if failed permission 0600 then alert",
		],
	}

	monit::check::file{"ha_cf":
		filepath => "/etc/ha.d/ha.cf",
		customlines => [
			"if failed checksum then alert",
		],
	}

	monit::check::file{"haresources":
		filepath => "/etc/ha.d/haresources",
		customlines => [
			"if failed checksum then alert",
		],
	}

	monit::check::process{"heartbeat":
		start 		=> "/etc/init.d/heartbeat start",
		stop		=> "/etc/init.d/heartbeat stop",
		depends_on  => ["ha_authkeys","ha_cf","haresources"],
	}

}
