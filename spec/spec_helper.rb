require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet'

RSpec.configure do |c|
  c.mock_with :rspec
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.default_facts = {
    :kernel          => 'Linux',
    :operatingsystem => 'CentOS',
    :operatingsystemrelease => '6.2',
    :osfamily        => 'RedHat'
  }

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
