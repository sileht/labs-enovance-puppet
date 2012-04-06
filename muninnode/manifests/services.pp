class muninnode::services {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      service { 'munin-node':
        ensure      => true,
        require     => Class['muninnode::packages']
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
