# puppetagent class
#
# == Parameters
# [server]
#   Puppet master URL
# [start]
#   *optional* enable/disable puppet client agent (default: true/enabled)
# [pluginsync]
#   *optional* enable/disable plugin sync (default: true/enabled)
# [daemonoptions]
#   *optional* add parameters to daemon
#
# == TODO
#
class puppetagent (
  $server           = $puppetagent::params::server,
  $start            = $puppetagent::params::start,
  $pluginsync       = $puppetagent::params::pluginsync,
  $daemonoptions    = $puppetagent::params::daemonoptions
) inherits puppetagent::params {
  include puppetagent::packages
  include puppetagent::services
  class { 'puppetagent::config':
    server          => $puppetagent::server,
    start           => $puppetagent::start,
    pluginsync      => $puppetagent::pluginsync,
    daemonoptions   => $puppetagent::daemonoptions
  }
}
