# Source: https://github.com/camptocamp/puppet-sudo.git
class sudo (
  # empty
) inherits sudo::params {
    include sudo::packages
}
