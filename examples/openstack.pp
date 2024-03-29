# params needed by compute & controller
#
# This example has been designed to be used in the context of http://wiki.debian.org/OpenStackPuppetHowto
#
# It can be used to deploy on a single host, by adding the following:
#
# node /single.host.com/ inherits controller {}
#
# And additional compute and volume hosts can be added by adding the following:
#
# node /compute1.host.com/ inherits compute {}
#
###

# The public fqdn of the controller host
$public_server = 'os.the.re'

# The internal fqdn of the controller host
$api_server = 'bm0001.the'

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
# TODO: change these two lines to exported variables 
$db_host = '192.168.100.1' # IP address of the host on which the database will be installed (the controller for instance)
$db_allowed_hosts = ['192.168.100.1', '192.168.100.2', '192.168.100.3', '192.168.100.4', '192.168.100.5', '192.168.100.6' ] # IP addresses for all compute hosts : they need access to the database


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


class role_nova_base {
  # NOTE(francois.charlier): to be included in Class['nova'] ?
  nova_config { "my_ip": value => $ipaddress_eth1 }

  class { 'nova':
    glance_api_servers            => "${glance_host}:9292",
    image_service                 => 'nova.image.glance.GlanceImageService',
    rabbit_host                   => $rabbit_host,
    sql_connection                => "mysql://${db_user}:${db_password}@${db_host}/${db_name}?charset=utf8",
    verbose                       => true,
  }

  nova_config { 'multi_host': value   => true }
  
}

class role_nova_controller {
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
}

class role_nova_compute {
  class { 'nova::compute':
    enabled                       => true,
    vncserver_proxyclient_address => $ipaddress_eth1,
    vncproxy_host	          => $public_server,
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

###
# Controller node
###
node controller {

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
    public_address   => $public_server,
    admin_address    => $public_server,
    internal_address => $api_server,
  }

  class { "nova::scheduler": enabled => true }

  class { "nova::vncproxy": enabled => true }

  class { "nova::consoleauth": enabled => true }

  class { "nova::keystone::auth":
    auth_name => $nova_auth,
    password  => $nova_pass,
    public_address   => $public_server,
    admin_address   => $public_server,
    internal_address   => $api_server,
  }
  Class['keystone::roles::admin'] -> Class['nova::keystone::auth']

  ###
  # Glance
  ###

  class { 'glance::keystone::auth':
    auth_name        => $glance_auth,
    password         => $glance_pass,
    public_address   => $public_server,
    admin_address    => $public_server,
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

  include role_nova_base
  include role_nova_controller
  include role_nova_compute

  class { 'nova::network':
    private_interface => 'eth1',
    public_interface  => 'eth0',
    fixed_range       => '10.145.0.0/16',
    floating_range    => false,
    network_manager   => $network_manager,
    config_overrides  => {
      vlan_start      => '2000',
    },
    create_networks => true,
    enabled         => true,
    install_service => true,
  }

  class { 'memcached':
    listen_ip => '127.0.0.1',
  }

  class { 'horizon':
    secret_key => 'unJidyaf8ow',
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
  nova_config { 'iscsi_ip_prefix': value => '192.168.' }
  class { 'nova::volume': }
  class { 'nova::volume::iscsi':
    volume_group	=> 'nova-volumes',
    iscsi_helper	=> 'iscsitarget',
  }
}

node compute {
  # Override path globally for all exec resources later
  Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin' }

  # While http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=668958 is not fixed in Wheezy
  package { 'lsb-base':
    ensure => latest,
    before => Class['nova'],
  }

  include role_nova_base
  include role_nova_compute

  class { 'nova::network':
    private_interface => 'eth1',
    public_interface  => 'eth0',
    fixed_range       => '10.145.0.0/16',
    floating_range    => false,
    network_manager   => $network_manager,
    config_overrides  => {
      vlan_start      => '2000',
    },
    create_networks => false,
    enabled         => true,
    install_service => true,
  }

  nova_config { 'enabled_apis': value => 'metadata' }

  nova_config { 'iscsi_ip_prefix': value => '192.168.' }
  class { 'nova::volume': }
  class { 'nova::volume::iscsi':
    volume_group	=> 'nova-volumes',
    iscsi_helper	=> 'iscsitarget',
  }
}
