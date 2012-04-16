# ssh class
#
# == Parameters
# none
# == TODO
# Add sshd_config parameters
#
class ssh (
) inherits ssh::params {
  include ssh::packages
  include ssh::services
  class { 'ssh::config':
    # empty for now
  }
}
