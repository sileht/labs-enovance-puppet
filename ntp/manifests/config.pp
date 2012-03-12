class ntp::config ( $ntpservers ) {
    File {
      owner => root,
      group => root,
      mode  => '0640',
    }

    file { '/etc/ntp.conf':
      ensure    => present,
      content   => template('ntp/ntp.conf.erb'),
      require   => Class['ntp::packages'],
      notify    => Class['ntp::services']
    }
}
