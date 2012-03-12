class snmp::config ($start, $daemonoptions, $sec_model, $users, $sources) {
  case $::operatingsystem {
    Debian, Ubuntu: {
      $confdir      = '/etc/snmp'
      $defaultdir   = '/etc/default'
    }
    default: {
      err("$::module class is for Debian-derived systems.")
      err("$::fqdn runs $::operatingsystem.")
    }
  }

  File {
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0760',
    require => Class['snmp::packages'],
    notify  => Class['snmp::services'],
  }

  file {
    $confdir:
      ensure  => directory;
    "$confdir/snmp.conf":
      content => template('snmp/snmp.conf.erb');
    "$confdir/snmpd_checks.conf":
      content => template('snmp/snmpd_checks.conf.erb');
    "$confdir/snmpd_acl.conf":
      content => template('snmp/snmpd_acl.conf.erb');
    "$confdir/snmpd.conf":
      source  => 'puppet:///modules/snmp/snmpd.conf';
    "$confdir/snmpd_contact.conf":
      content => template('snmp/snmpd_contact.conf.erb');
    "$confdir/snmptrapd.conf":
      content => template('snmp/snmptrapd.conf.erb');
    "$defaultdir/snmpd":
      content => template('snmp/default/snmpd.erb'),
  }
}
