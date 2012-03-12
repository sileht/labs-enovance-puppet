class muninnode::config ( $sources, $port ) {
    File {
      owner => root,
      group => root,
      mode  => '0640',
    }

    file { '/etc/munin/munin-node.conf':
      ensure    => present,
      content   => template('muninnode/munin-node.conf.erb'),
      require   => Class['muninnode::packages'],
      notify    => Class['muninnode::services'],
    }
}
