class ssh::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'openssh-server':
          ensure => present;
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
