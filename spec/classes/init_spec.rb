require 'spec_helper'

describe 'geminabox', :compile do
  let(:pre_condition) { "rvm_system_ruby {'1.9': ensure => 'present'}" }
  it { should contain_service('geminabox') }
end
