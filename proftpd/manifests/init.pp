class proftpd
{
  file { proftpd-preseed:
    path => "/var/cache/debconf/proftpd",
    owner => root, group => root, mode => 400,
    source => "puppet://$puppetserver/modules/proftpd/proftpd.preseed",
  }

  package { proftpd:
    ensure => present,
    responsefile => "/var/cache/debconf/proftpd.preseed",
    require => File[proftpd-preseed],
  }

  file { '/etc/proftpd/proftpd.conf':
    owner => root,
    group => root,
    mode  => 0644,
    source => "puppet://$puppetserver/modules/proftpd/etc/proftpd/proftpd.conf",
    require => Package['proftpd'],
  }

  service { proftpd:
    ensure => running,
    subscribe => File["/etc/proftpd/proftpd.conf"],
  }
}
