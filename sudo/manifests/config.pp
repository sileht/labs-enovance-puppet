class sudo::config {
  file { '/etc/sudoers':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0440',
  }

  if versioncmp($sudo::sudoversion,'1.7.2') < 0 {
    #
    # Backward compatibility for version less than 1.7.2
    #
    common::concatfilepart { '000-sudoers.init':
      ensure  => present,
      manage  => true,
      file    => '/etc/sudoers',
      content => template('sudo/sudoers.erb'),
    }
  } else {
    #
    # Use the #includedir directive to manage sudoers.d, version >= 1.7.2
    #
    file {'/etc/sudoers.d':
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0755',
      purge   => true,
      recurse => true,
    }

    File ['/etc/sudoers'] {
      content => template('sudo/sudoers.erb')
    }
  }
}
