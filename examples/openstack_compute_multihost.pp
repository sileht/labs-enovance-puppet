###
# params needed by compute & controller
###

# The fqdn of the proxy host
$api_server = 'controller'

# Mysql database root password. MySQL will be used for nova, keystone and glance. 
$db_rootpassword = 'dummy_password'

## Nova

# Networking strategy
$network_manager = 'nova.network.manager.VlanManager'
$multi_host_networking = true

# Nova db config
$db_password = 'dummy_nova_password'
$db_name = 'nova'
$db_user = 'nova'
# TODO: change these two lines to exported variables …
$db_host = '192.168.66.100' # private address for the controller !!!
$db_allowed_hosts = ['192.168.66.1', '192.168.66.2'] # private addresses for the compute nodes !!!

# Rabbitmq config
$rabbit_host = $api_server

# Hypervisor
$libvirt_type = 'kvm'

# nova user declared in keystone
$nova_auth = 'nova'
$nova_pass = 'nova_pass'

## Keystone

# Keystone db config
$keystone_db_password = 'dummy_keystone_password'
$keystone_db_name = 'keystone'
$keystone_db_user = 'keystone'

# Keystone admin credendials
$keystone_admin_token = 'admin_token'
$keystone_admin_email = 'test@example.com'
$keystone_admin_pass = 'admin_pass'

# Keystone services tenant (_/!\_ do not change _/!\_)
$services_tenant = 'services'

## Glance

# Glance host
$glance_host = $api_server

# Glance db config
$glance_db_password = 'dummy_glance_password'
$glance_db_name = 'glance'
$glance_db_user = 'glance'

# glance user declared in keystone
$glance_auth = 'glance'
$glance_pass = 'glance_pass'

###
# Overrides
###

# Specify a sane default path for Execs
Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

# Purge variables not explicitly set in this manifest
resources { 'nova_config':
  purge => true,
}


###
# Controller node
###
node /controller/ {

  # While http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=668958 is not fixed in Wheezy
  package { 'lsb-base':
    ensure => latest,
    before => Class['mysql::server'],
  }


  ###
  # Mysql server, required by nova, keystone & glance
  ###
  class { 'mysql::server':
    config_hash => {
      # eth1 is our private network interface
      bind_address  => $ipaddress_eth1,
      root_password => $db_rootpassword,
    }
  }

  ###
  # Keystone
  ###

  class { 'keystone::db::mysql':
    password => $keystone_db_password,
    dbname   => $keystone_db_name,
    user     => $keystone_db_user,
    host     => 'localhost',
    require  => Class['mysql::server'],
  }

  class { 'keystone':
    admin_token  => $keystone_admin_token,
    log_verbose  => true,
    log_debug    => true,
    compute_port => 8774,
    catalog_type => 'sql'
  }

  class { 'keystone::config::mysql':
    user     => $keystone_db_user,
    password => $keystone_db_password,
    host     => 'localhost',
    dbname   => $keystone_db_name,
  }
  Class['keystone::db::mysql'] -> Class['keystone::config::mysql']

  # Creates an 'admin' keystone user in tenant named 'openstack'
  class { 'keystone::roles::admin':
    email    => $keystone_admin_email,
    password => $keystone_admin_pass,
  }
  Class['keystone'] -> Class['keystone::roles::admin']
  Class['keystone::config::mysql'] -> Class['keystone::roles::admin']

  class { 'keystone::endpoint':
    public_address   => $api_server,
    admin_address    => $api_server,
    internal_address => $api_server,
  }


  ###
  # Nova
  ###

  class { 'nova::rabbitmq':
  }

  class { 'nova::db::mysql':
    # pass in db config as params
    password      => $db_password,
    dbname        => $db_name,
    user          => $db_user,
    host          => 'localhost',
    allowed_hosts => $db_allowed_hosts,
    require       => Class['mysql::server'],
  }

  class { "nova":
    sql_connection        => "mysql://${db_user}:${db_password}@$localhost/${db_name}?charset=utf8",
    image_service         => 'nova.image.glance.GlanceImageService',
    glance_api_servers    => "${glance_host}:9292",
    rabbit_host           => $rabbit_host,
    network_manager       => $network_manager,
    multi_host_networking => $multi_host_networking,
    vlan_interface        => 'eth1',
    vlan_start            => 2000,
    verbose               => $verbose,
  }
  Class['nova::db::mysql'] -> Class['nova']

  class { "nova::api":
    enabled           => true,
    auth_host         => $api_server,
    admin_tenant_name => $admin_tenant_name,
    admin_user        => $nova_auth,
    admin_password    => $nova_pass,
  }

  class { "nova::objectstore":
    enabled => true,
  }

  class { "nova::cert":
    enabled => true,
  }

  # NOTE(fcharlier): to be included in Class['nova'] ?
  nova_config { "my_ip": value => $ipaddress_eth1 }

  class { "nova::scheduler": enabled => true }

  class { "nova::vncproxy": enabled => true }

  class { "nova::consoleauth": enabled => true }

  class { "nova::keystone::auth":
    auth_name => $nova_auth,
    password  => $nova_pass,
    address   => $api_server,
  }
  Class['keystone::roles::admin'] -> Class['nova::keystone::auth']

  ###
  # Glance
  ###

  class { 'glance::keystone::auth':
    auth_name        => $glance_auth,
    password         => $glance_pass,
    public_address   => $api_server,
    admin_address    => $api_server,
    internal_address => $api_server,
  }
  Class['keystone::roles::admin'] -> Class['nova::keystone::auth']

  class { 'glance::api':
    log_verbose       => 'True',
    log_debug         => 'True',
    auth_type         => 'keystone',
    auth_host         => $api_server,
    auth_uri          => "http://${api_server}:5000/v2.0/",
    keystone_tenant   => $services_tenant,
    keystone_user     => $glance_auth,
    keystone_password => $glance_pass,
  }

  class { 'glance::backend::file':
  }

  class { 'glance::db::mysql':
    password       => $glance_db_password,
    dbname         => $glance_db_name,
    user           => $glance_db_user,
    host           => 'localhost',
    require        => Class['mysql::server'],
  }

  class { 'glance::registry':
    log_verbose       => 'True',
    log_debug         => 'True',
    auth_type         => 'keystone',
    keystone_tenant   => $services_tenant,
    keystone_user     => $glance_auth,
    keystone_password => $glance_pass,
    sql_connection    => "mysql://${glance_db_user}:${glance_db_password}@localhost/${glance_db_name}"
  }

  ###
  # rcfile for tests
  ###
  file { '/root/openrc.sh':
    ensure  => present,
    group   => 0,
    owner   => 0,
    mode    => '0600',
    content => "export OS_PASSWORD=${keystone_admin_pass}
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export OS_USERNAME=admin
export OS_TENANT_NAME=openstack
"

  }

}

node /compute/ {
  # Override path globally for all exec resources later
  Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin' }

  # While http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=668958 is not fixed in Wheezy
  package { 'lsb-base':
    ensure => latest,
    before => Class['nova'],
  }

  # NOTE(francois.charlier): to be included in Class['nova'] ?
  nova_config { "my_ip": value => $ipaddress_eth1 }

  class { 'nova':
    verbose                       => true,
    sql_connection                => "mysql://${db_user}:${db_password}@${db_host}/${db_name}?charset=utf8",
    multi_host_networking         => true,
    rabbit_host                   => $rabbit_host,
    network_manager               => $network_manager,
    vlan_interface                => 'eth1',
    vlan_start                    => '2000',
    image_service                 => 'nova.image.glance.GlanceImageService',
    glance_api_servers            => "${glance_host}:9292",
  }
  class { 'nova::compute::multi_host':
    enabled => true,
  }
  class { 'nova::compute':
    enabled                       => true,
    vncserver_proxyclient_address => $ipaddress_eth1,
    novncproxy_base_url           => "http://${api_server}:6080/vnc_auto.html",
  }
  class { 'nova::compute::libvirt':
    libvirt_type     => $libvirt_type,
    vncserver_listen => $ipaddress_eth1,
  }

  # FIXME: to be included in the nova module ?
  # NOTE: inspired from http://projects.puppetlabs.com/projects/1/wiki/Kernel_Modules_Patterns
  # Activate nbd module (for qemu-nbd)
  exec { "insert_module_nbd":
    command => "/bin/echo 'nbd' > /etc/modules",
    unless  => "/bin/grep 'nbd' /etc/modules",
  }
  exec { "/sbin/modprobe nbd":
    unless => "/bin/grep -q '^nbd ' '/proc/modules'"
  }
}
