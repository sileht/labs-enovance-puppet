class ntp::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'ntp':
          ensure    => present,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
