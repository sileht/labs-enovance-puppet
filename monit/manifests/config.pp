class monit::config (
  $start        = $monit::params::start,
  $email        = $monit::params::email
) {
  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      $confdir = '/etc/monit'
      $monitd = '/etc/monit/conf.d'

      File {
        owner => root,
        group => root,
        mode  => '0640',
      }

      file {
        $confdir:
          ensure  => directory;
        $monitd:
          ensure  => directory;
        "$confdir/monitrc":
          ensure  => present,
          owner   => root,
          group   => root,
          mode    => '0700',
          content => template('monit/monitrc.erb'),
          require => File[$confdir],
          notify  => Class['monit::services'];
      }

      file { '/etc/default/monit':
        ensure  => present,
        content => template('monit/monit.erb'),
        require => Class['monit::packages'],
        notify  => Class['monit::services'];
      }
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }
}
