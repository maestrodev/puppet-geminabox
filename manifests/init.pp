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
#   rvm_path:     the path that the rvm binary can be found in
#   rvm_deps:     wait for these resource deps before attempting installing the version of ruby we care about via rvm
#   ruby_version: the version of ruby we want to ensure is installed and use in our init script
#   manage_user:  whether or not to manage the user resource for the given user
#   manage_group: whether or not to manage the group resource for the given group
#   manage_data_dir: whether or not to manage the data directory (disable if file resource is externally created)
#   manage_config_dir: whether or not to manage the config directory (disable if file resource is externally created)
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
  $config_dir   = "/etc/geminabox",
  $data_dir     = "/var/lib/geminabox",
  $log_file     = "/var/log/geminabox.log",
  $pid_file     = "/var/run/geminabox.pid",
  $service_name = "geminabox",
  $user         = "geminabox",
  $group        = "geminabox",
  $version      = "~> 0.10.1",
  $port         = 8080,
  $thin_options = "-d",
  $rvm_path     = "/usr/local/rvm/bin",
  $rvm_deps     = [Class["rvm"]],
  $ruby_version = "1.9.3",
  $manage_user  = true,
  $manage_group = true,
  $manage_data_dir = true,
  $manage_config_dir = true,
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
      home       => $root,
      managehome => true,
    }
  }

  # ensure directories exist
  if $manage_config_dir {
    file { $config_dir:
      ensure => 'directory',
      owner => $user,
      group => $group,
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
  file { "$config_dir/$service_name.ru":
    ensure => 'present',
    content => template('geminabox/config.ru.erb'),
    owner => $user,
    group => $group,
  }

  file { "/etc/init.d/$service_name":
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '755',
    content => template('geminabox/geminabox.init.erb')
  }

  file { $log_file:
    ensure => 'present',
    owner  => $user,
    group  => $group,
  }

  # ensure the correct version of ruby is installed, along with the thin & geminabox gems
  # TODO - see if there's a cleaner way of getting theme gems installed for
  # the specific ruby version. the login shell is needed for rvm to be happy
  exec { "geminabox-install-ruby-$ruby_version":
    path    => [ $rvm_path, "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "bash --login -c 'rvm install $ruby_version'",
    unless  => "bash --login -c 'rvm list | egrep $ruby_version'",
    require => $rvm_deps,
  }
  exec { "geminabox-install-thin":
    path    => [ $rvm_path, "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "bash --login -c 'rvm use $ruby_version && `which gem` install thin'",
    unless  => "bash --login -c 'rvm use $ruby_version && `which gem` list | egrep thin'",
    require => Exec["geminabox-install-ruby-$ruby_version"],
  }
  exec { "geminabox-install-geminabox":
    path    => [ $rvm_path, "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "bash --login -c 'rvm use $ruby_version && `which gem` install geminabox'",
    unless  => "bash --login -c 'rvm use $ruby_version && `which gem` list | egrep geminabox'",
    require => Exec["geminabox-install-thin"],
  }

  # ensure the geminabox service is running
  service { $service_name:
    ensure     => 'running',
    enable     => true,
    require    => Exec["geminabox-install-geminabox"],
    hasstatus  => true,
    subscribe  => [
      File["$config_dir/$service_name.ru"],
    ],
  }
}
