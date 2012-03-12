class postfix::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'postfix':
          ensure    => installed,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
