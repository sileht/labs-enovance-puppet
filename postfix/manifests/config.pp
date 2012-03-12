class postfix::config ($client, $sasl) {
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      $confdir      = '/etc/postfix'

      File {
        owner   => root,
        group   => root,
        mode    => 0760,
        ensure  => 'present',
        require => Class['postfix::packages'],
        notify  => Class['postfix::services'],
      }

      file {
        $confdir:
          ensure  => directory;
        "$confdir/main.cf":
          content => template('postfix/main.cf.erb');
        "$confdir/master.cf":
          content => template('postfix/master.cf.erb');
        "$confdir/sasl_passwd":
          content => template('postfix/sasl_passwd.erb'),
          notify  => Exec['postmap-sasl'];
        '/etc/mailname':
          ensure => link,
          target => '/etc/hostname';
      }

      exec { 'postmap-sasl':
        command     => "/usr/sbin/postmap $confdir/sasl_passwd",
        refreshonly => true,
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
