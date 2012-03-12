# ocsinventory class
#
# == Parameters
# [url]
#   OCS inventory server URL
#
# == TODO
#
class ocsinventory (
  $url           = $ocsinventory::params::url
) inherits ocsinventory::params {
  include ocsinventory::packages
  class { 'ocsinventory::config':
    url          => $ocsinventory::url,
  }
}
