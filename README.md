# geminabox

Installs and manages Gem In A Box

Requirements: rvm (must install rvm using `maestrodev/rvm` module)

    rvm_system_ruby { '1.9':
      ensure      => 'present',
    }
    class { 'geminabox': }

See [manifests/init.pp](manifests/init.pp) for documentation and example usage.

Thanks to David Goodlad for the initial puppet module that served as the base for this module
