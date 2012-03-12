# resolver class
#
# == Parameters
# [dcinfo]
#   This parameter contains is an hash containing the list 
#   of you NS depending on their location in your datacenters.
# [domainname]
#   Local domain name.
# [searchpath]
#   Search list for host-name lookup.
# [*publicdns*]
#   *optional* add public DNS (backup)
#
# == Examples
# Here is an example of the dcinfo parameter:
#  class { 'resolver':
#    dcinfo      => { dc1   => ['1.2.3.4', '5.6.7.8', '9.0.1.2'],
#                     dc2   => ['3.4.5.6', '7.8.9.1', '2.3.4.5']
#                },
#    domainname  => 'enovance.com',
#    searchpath  => 'enovance.com',
#    publicdns   => ['8.8.8.8'],
#  }
#
# Original source:
#   http://projects.puppetlabs.com/projects/1/wiki/Resolv_Conf_Patterns

class resolver (
  $dcinfo       = $resolver::params::dcinfo,
  $publicdns    = $resolver::params::publicdns,
  $domainname    = $resolver::params::domainname,
  $searchpath    = $resolver::params::searchpath
) inherits resolver::params {
  class { 'resolver::config':
    dcinfo    => $resolver::dcinfo,
    publicdns => $resolver::publicdns,
    domainname => $resolver::domainname,
    searchpath => $resolver::searchpath
  }
}
