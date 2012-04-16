class ssh::services {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      service { 'ssh':
       ensure      => true,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
