class ssh::packages {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      package {
        'openssh-server':
          ensure => installed;
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
