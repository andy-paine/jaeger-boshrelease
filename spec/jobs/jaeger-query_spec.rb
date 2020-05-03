require 'rspec'
require 'bosh/template/test'
require_relative '../spec_helper.rb'

# Specific tests for behaviour only used in jaeger-query
describe 'jaeger-query: specific configuration' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('jaeger-query') }
  let(:template) { job.template('config/bpm.yml') }
  let(:config) { es_config }

  it 'uses the correct admin port' do
    args = get_process_from_bpm(YAML::load(template.render(config)), 'jaeger-query')['args']
    expect(args).to include '--admin-http-port=14271'
  end

  it 'only allows supported span_storage_types' do
    expect{ template.render({'span_storage_type' => 'elasticsearch', 'es' => { 'server-urls' => ['foo']}}) }.not_to raise_error
    expect{ template.render({'span_storage_type' => 'memory'}) }.to raise_error('memory is not a supported span_storage_type for jaeger-query')
    expect{ template.render({'span_storage_type' => 'badger'}) }.to raise_error('badger is not a supported span_storage_type for jaeger-query')
    expect{ template.render({'span_storage_type' => 'foo'}) }.to raise_error('foo is not a supported span_storage_type for jaeger-query')
  end
end