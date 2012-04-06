class muninnode::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'munin-node':
          ensure    => present,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
