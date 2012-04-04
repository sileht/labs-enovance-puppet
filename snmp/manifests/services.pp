class snmp::services {
  case $::operatingsystem {
    Debian, Ubuntu: {
      service { 'snmpd':
        ensure      => true,
        require     => Class['snmp::packages']
      }
    }

    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
