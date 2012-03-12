class snmp::params {
  $start            = 'yes'
  $daemonoptions    = '-Lsd -Lf /dev/null -u snmp -I -smux -p /var/run/snmpd.pid 127.0.0.1'
  $sec_model        = []
  $users            = {}
  $sources          = {}
}
