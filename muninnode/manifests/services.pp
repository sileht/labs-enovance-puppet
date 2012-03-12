class muninnode::services {
    service { 'munin-node':
        ensure      => true,
        require     => Class['muninnode::packages']
    }
}
