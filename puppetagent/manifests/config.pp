class puppetagent::config ( $server, $start, $pluginsync, $daemonoptions) {
    File {
      owner => 'root',
      group => 'root',
      mode  => 0640,
    }

    file { '/etc/puppet/puppet.conf':
      ensure  => present,
      content => template('puppetagent/puppet.conf.erb'),
      require => Class['puppetagent::packages'],
      notify  => Class['puppetagent::services'],
    }

    file { '/etc/default/puppet':
      ensure  => present,
      content => template('puppetagent/puppet.erb'),
      require => Class['puppetagent::packages'],
      notify  => Class['puppetagent::services'],
    }
}
