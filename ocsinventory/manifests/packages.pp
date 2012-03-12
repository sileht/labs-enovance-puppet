class ocsinventory::packages {
    package { 'ocsinventory-agent':
      ensure => present,
    }
}
