class ntp::packages {
    package { 'ntp':
      ensure => present,
    }
}
