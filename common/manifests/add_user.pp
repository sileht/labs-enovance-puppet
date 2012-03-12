#
# add new user/password and update user password
#
# source: http://itand.me/using-puppet-to-manage-users-passwords-and-ss
define common::add_user (
  $email,
  $password,
  $groups,
  $sshkey_type,
  $sshkey, $sshkey_name )
  {

  $username = $title
  $homedir  = "/home/$username"

  user { $username:
    comment     => $email,
    home        => "/home/$username",
    shell       => '/bin/bash',
    password    => $password,
    groups      => $groups,
  }

  group { $username:
    require     => User[$username],
  }

  file { $homedir:
    ensure      => directory,
    owner       => $username,
    group       => $username,
    mode        => '0750',
    require     => [ User[$username], Group[$username] ],
  }

  file { "$homedir/.ssh":
    ensure      => directory,
    owner       => $username,
    group       => $username,
    mode        => '0700',
    require     => File[$homedir],
  }

  file { "$homedir/.ssh/authorized_keys":
    ensure      => present,
    owner       => $username,
    group       => $username,
    mode        => '0600',
    require     => File[$homedir]
  }

  ssh_authorized_key{ $sshkey_name:
    ensure      => present,
    key         => $sshkey,
    type        => $sshkey_type,
    user        => $username,
    require     => File["$homedir/.ssh/authorized_keys"]
  }
}
