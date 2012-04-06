class ntp::services {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      service { 'ntp':
        ensure      => true,
        require     => Class['ntp::packages']
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
