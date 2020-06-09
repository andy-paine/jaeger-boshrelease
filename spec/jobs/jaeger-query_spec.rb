require 'rspec'
require 'bosh/template/test'
require_relative '../spec_helper'
require_relative '../common_config'
require_relative '../query_config'

describe 'jaeger-query' do
  job_name = 'jaeger-query'
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job(job_name) }
  let(:template) { job.template('config/bpm.yml') }
  let(:config) { es_config }

  it_should_behave_like 'a jaeger component', job_name
  it_should_behave_like 'an elasticsearch connected component', job_name
  it_should_behave_like 'a queryable component', job_name

  it 'uses the correct admin port' do
    args = get_process_from_bpm(YAML::load(template.render(config)), job_name)['args']
    expect(args).to include '--admin-http-port=14271'
  end

  it 'only allows supported span_storage_types' do
    expect{ template.render({'span_storage_type' => 'elasticsearch', 'es' => { 'server-urls' => ['foo']}}) }.not_to raise_error
    expect{ template.render({'span_storage_type' => 'memory'}) }.to raise_error('memory is not a supported span_storage_type for jaeger-query')
    expect{ template.render({'span_storage_type' => 'badger'}) }.to raise_error('badger is not a supported span_storage_type for jaeger-query')
    expect{ template.render({'span_storage_type' => 'foo'}) }.to raise_error('foo is not a supported span_storage_type for jaeger-query')
  end
end