class monit::services {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      service { 'monit':
        ensure      => true,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
