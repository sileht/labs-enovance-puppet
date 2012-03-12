class snmp::services {
    service { 'snmpd':
        ensure      => true,
        require     => Class['snmp::packages']
    }
}
