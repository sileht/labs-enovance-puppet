require 'spec_helper'
describe 'postfix' do
  it { should include_class('postfix::config') }
  it { should include_class('postfix::packages') }
  it { should include_class('postfix::params') }
  it { should include_class('postfix::services') }
end
