require 'rspec'
require 'bosh/template/test'
require_relative '../spec_helper.rb'

# Specific tests for behaviour only used in jaeger-agent
describe 'jaeger-agent' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('jaeger-agent') }
  let(:template) { job.template('config/bpm.yml') }

  it 'uses the correct admin port' do
    args = get_process_from_bpm(YAML::load(template.render({})), 'jaeger-agent')['args']
    expect(args).to include '--admin-http-port=14269'
  end
end