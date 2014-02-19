# geminabox

Installs and manages Gem In A Box

Requirements: rvm (must install rvm using `maestrodev/rvm` module)

    rvm_system_ruby { '1.9':
      ensure      => 'present',
    }
    class { 'geminabox': }

## Parameters:

* config_dir:   the rack application's configuration, where the <service_name>.ru rack config will live
* data_dir:     where geminabox will store all of its data - gems, index, etc.
* log_file:     where the thin logs will be written
* pid_file:     where the thin pidfile will be located
* service_name: the name of the service (this affects the configuration file, init script, and process name)
* user:         the user to own and run geminabox
* group:        the group to own and run geminabox
* version:      a rubygem-style version, specifying the desired geminabox version
* port:         port on which the geminabox http server will listen
* thin_options: any additional params to pass to thin (see templates/geminabox.init.erb for what's already set)
* rvm_path:     the path that the rvm binary can be found in
* rvm_deps:     wait for these resource deps before attempting installing the version of ruby we care about via rvm
* ruby_version: the version of ruby we want to ensure is installed and use in our init script
* manage_user:  whether or not to manage the user resource for the given user
* manage_group: whether or not to manage the group resource for the given group
* manage_data_dir: whether or not to manage the data directory (disable if file resource is externally created)
* manage_config_dir: whether or not to manage the config directory (disable if file resource is externally created)

## Usage

    class { 'geminabox':
      port => '8081',
    }

Note that this module defines the 'thin' package, which may conflict with other modules you include.

## Credits

Thanks to David Goodlad for the initial puppet module that served as the base for this module
