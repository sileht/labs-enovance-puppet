class resolver::config ( $dcinfo, $domainname, $searchpath, $publicdns ) {
  file { '/etc/resolv.conf':
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('resolver/resolv.conf.erb'),
  }
}
