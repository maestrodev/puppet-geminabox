# Class geminabox
#
# Parameters:
#
#   root:    the rack application's root directory, where config.ru will live
#   datadir: where geminabox will store all of its data - gems, index, etc.
#   user:    the user to own and run geminabox
#   group:   the group to own and run geminabox
#   version: a rubygem-style version, specifying the desired geminabox version
#   port:    port on which the geminabox http server will listen
#
# Example Usage:
#
#   class { 'geminabox':
#     port => '8081',
#   }
#
# Note that this module defines the 'thin' package, which may conflict with
# other modules you include.
#
class geminabox (
  $root    = "/opt/geminabox",
  $datadir = "/var/lib/geminabox",
  $user    = "geminabox",
  $group   = "geminabox",
  $version = "~> 0.8",
  $port    = 8080,
) {
  group { $group:
    ensure => 'present',
    system => true,
  }

  user { $user:
    ensure     => 'present',
    system     => true,
    gid        => $group,
    home       => $root,
    managehome => true,
  }

  file { $datadir:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
    mode   => '0750',
  }

  file { $root:
    ensure => 'directory',
    owner => $user,
    group => $group,
    require => User[$user],
  }

  file { "$root/config.ru":
    ensure => 'present',
    content => template('geminabox/config.ru.erb'),
    owner => $user,
    group => $group,
  }

  package { 'thin':
    provider => 'gem',
    ensure   => 'present',
  }

  package { 'geminabox':
    provider => 'gem',
    ensure   => $version,
  }

  file { '/etc/init/geminabox.conf':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    content => template('geminabox/geminabox.conf.erb')
  }

  service { 'geminabox':
    ensure     => 'running',
    enable     => true,
    subscribe => [
      File['/etc/init/geminabox.conf'],
      File["$root/config.ru"],
    ],
  }
}
