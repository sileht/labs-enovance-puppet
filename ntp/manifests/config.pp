class ntp::config ( $ntpservers ) {
    File {
      owner => root,
      group => root,
      mode  => '0640',
      require   => Class['ntp::packages'],
      notify    => Class['ntp::services']
    }

  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      file { '/etc/ntp.conf':
        ensure    => present,
        content   => template('ntp/ntp.conf.erb'),
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
