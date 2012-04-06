class monit::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'monit': ensure => present;
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
