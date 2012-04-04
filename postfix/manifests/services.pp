class postfix::services {
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      service { 'postfix':
        ensure      => true,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
