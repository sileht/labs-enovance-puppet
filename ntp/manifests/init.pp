# ntp class
#
# == Parameters
# [ntpservers]
#   list of NTP servers. Default points to the Debian defaults.
#
# == TODO
#
class ntp (
  $ntpservers           = $ntp::params::ntpservers
) inherits ntp::params {
  include ntp::packages
  include ntp::services
  class { 'ntp::config':
    ntpservers          => $ntp::ntpservers,
  }
}
