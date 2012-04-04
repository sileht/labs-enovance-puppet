class postfix::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'postfix':
          ensure    => present,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
