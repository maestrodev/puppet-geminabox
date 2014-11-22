# Class geminabox
#
# Parameters:
#
#   config_dir:   the rack application's configuration, where the <service_name>.ru rack config will live
#   data_dir:     where geminabox will store all of its data - gems, index, etc.
#   log_file:     where the thin logs will be written
#   pid_file:     where the thin pidfile will be located
#   service_name: the name of the service (this affects the configuration file, init script, and process name)
#   user:         the user to own and run geminabox
#   group:        the group to own and run geminabox
#   version:      a rubygem-style version, specifying the desired geminabox version
#   port:         port on which the geminabox http server will listen
#   thin_options: any additional params to pass to thin (see templates/geminabox.init.erb for what's already set)
#   ruby_version: the version of ruby we want to ensure is installed and use in our init script
#   manage_user:  whether or not to manage the user resource for the given user
#   manage_group: whether or not to manage the group resource for the given group
#   manage_data_dir: whether or not to manage the data directory (disable if file resource is externally created)
#   manage_config_dir: whether or not to manage the config directory (disable if file resource is externally created)
#   proxy_url: url and port to http proxy for use with rvm (example: http://proxy.domain.tld:80)
#   rubygems_proxy: whether or not to enable the rubygems proxy feature in geminabox
#   allow_remote_failure: whether or not to enable the allow remote failure feature in geminabox
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
  $config_dir   = '/etc/geminabox',
  $data_dir     = '/var/lib/geminabox',
  $log_file     = '/var/log/geminabox.log',
  $pid_file     = '/var/run/geminabox.pid',
  $service_name = 'geminabox',
  $user         = 'geminabox',
  $group        = 'geminabox',
  $version      = 'present',
  $port         = 8080,
  $thin_options = '-d',
  $ruby_version = '1.9',
  $manage_user  = true,
  $manage_group = true,
  $manage_data_dir = true,
  $manage_config_dir = true,
  $proxy_url = undef,
  $rubygems_proxy = false,
  $allow_remote_failure = false,
) {

  # manage users and groups
  if $manage_group {
    group { $group:
      ensure => 'present',
      system => true,
    }
  }

  if $manage_user {
    user { $user:
      ensure     => 'present',
      system     => true,
      gid        => $group,
      home       => $::root,
      managehome => true,
    }
  }

  # ensure directories exist
  if $manage_config_dir {
    file { $config_dir:
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      require => User[$user],
    }
  }

  if $manage_data_dir {
    file { $data_dir:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0770',
    }
  }

  # ensure necessary files are present/copied
  file { "${config_dir}/${service_name}.ru":
    ensure  => 'present',
    content => template('geminabox/config.ru.erb'),
    owner   => $user,
    group   => $group,
  }

  file { "/etc/init.d/${service_name}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('geminabox/geminabox.init.erb')
  }

  file { $log_file:
    ensure => 'present',
    owner  => $user,
    group  => $group,
  }

  Rvm_gem {
    ruby_version => $ruby_version,
    before       => Service[$service_name],
  }

  rvm_gem { 'thin':
    ensure    => present,
    proxy_url => $proxy_url,
  }
  rvm_gem { 'geminabox':
    ensure    => $version,
    proxy_url => $proxy_url,
  }

  # ensure the geminabox service is running
  service { $service_name:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => [File["${config_dir}/${service_name}.ru"]],
  }
}
