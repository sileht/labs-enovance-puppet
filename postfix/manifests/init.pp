# postfix class
#
# == Parameters
# [client]
#   *optional* set client name used for sasl authentification with MX
# [sasl_passwd]
#   *optional* if set to 'none', no authentification will be configured
#
# == TODO
# * Add the auto-provisionning/generation of client/password to MX
#
class postfix (
  $client       =   $postfix::params::client,
  $sasl         =   $postfix::params::sasl
) inherits postfix::params {
    include postfix::packages
    include postfix::services
    class { 'postfix::config':
        client      => $postfix::client,
        sasl        => $postfix::sasl
    }
}
