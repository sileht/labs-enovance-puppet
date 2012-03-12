class snmp (
  $start            = $snmp::params::start,
  $daemonoptions    = $snmp::params::daemonoptions,
  $sec_model        = $snmp::params::sec_model,
  $users            = $snmp::params::users,
  $sources          = $snmp::params::sources
) inherits snmp::params {
    include snmp::packages
    include snmp::services
    class { 'snmp::config':
        start           => $snmp::start,
        daemonoptions   => $snmp::daemonoptions,
        users           => $snmp::users,
        sources         => $snmp::sources,
        sec_model       => $snmp::sec_model
    }
}
