require 'spec_helper'
describe 'sudo' do
  it { should include_class('sudo::config') }
  it { should include_class('sudo::packages') }
  it { should include_class('sudo::params') }
  it { should include_class('sudo::services') }
end
