# muninnode class
#
# == Parameters
# [sources]
#   Hash of munin servers sources
# [port]
#   Set munin-node port (default: 4949)
#
# == TODO
# Add munin files to required modules
#
class muninnode (
  $sources      = $muninnode::params::sources,
  $port         = $muninnode::params::port
) inherits muninnode::params {
  include muninnode::packages
  include muninnode::services
  class { 'muninnode::config':
    sources     => $muninnode::sources,
    port        => $muninnode::port
  }
}
