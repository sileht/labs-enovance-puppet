require 'spec_helper'
describe 'monit' do
  it { should include_class('monit::config') }
  it { should include_class('monit::packages') }
  it { should include_class('monit::params') }
  it { should include_class('monit::services') }
end
