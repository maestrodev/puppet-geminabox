require 'spec_helper'

describe 'geminabox' do
  
  it { should contain_service('geminabox').with_ensure('running') }
  
end
