class snmp::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'snmp':
          ensure    => installed,
          require   => Class['enovance'],
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
