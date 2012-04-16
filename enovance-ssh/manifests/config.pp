class ssh::config () {
  case $::operatingsystem {
    Debian, Ubuntu: {
      $confdir      = '/etc/ssh'
      $defaultdir   = '/etc/default'
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }

  File {
    owner   => root,
    group   => root,
    mode    => 0760,
    ensure  => present,
    notify  => Class['ssh::services'],
    require => Class['ssh::packages'],
  }

  file {
    $confdir:
      ensure  => directory;
  }
}
