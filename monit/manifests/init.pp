# monit class
#
# == Parameters
# [start]
#   *optional* set to 0 to disable monit (default: 1)
# == Description
# Install and configure the monit package
#
class monit (
  $start = $monit::params::start,
  $email = $monit::params::email
) inherits monit::params {
  include monit::packages
  include monit::services
  class { 'monit::config':
    start => $monit::start,
    email => $monit::email
  }
}
