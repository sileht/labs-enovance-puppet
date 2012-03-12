class ocsinventory::config ( $url ) {
    File {
      owner => root,
      group => root,
      mode  => '0640',
    }

    file { '/etc/ocsinventory/ocsinventory-agent.cfg':
      ensure    => present,
      content   => template('ocsinventory/ocsinventory-agent.cfg.erb'),
      require   => Class['ocsinventory::packages'],
      notify    => Exec['ocs-update']
    }

    exec { 'ocs-update':
      command     => '/usr/bin/ocsinventory-agent',
      refreshonly => true,
    }

}
