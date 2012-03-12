define monit::add_service()
{
  file { $name:
    ensure  => present,
    path    => "$monit::config::monitd/${name}",
    content => template("monit/conf.d/${name}.erb"),
    group   => root,
    require => File[$monit::config::confdir],
    notify  => Class['monit::services'],
    mode    => '0700';
  }
}
