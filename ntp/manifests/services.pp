class ntp::services {
    service { 'ntp':
        ensure      => true,
        require     => Class['ntp::packages']
    }
}
