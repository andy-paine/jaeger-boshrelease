require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative '../spec_helper'
require_relative '../collector_config'
require_relative '../common_config'
require_relative '../elasticsearch_config'
require_relative '../processor_config'
require_relative '../query_config'

describe 'jaeger-all-in-one' do
  job_name = 'jaeger-all-in-one'
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job(job_name) }
  let(:template) { job.template('config/bpm.yml') }
  let(:config) { es_config }

  it_should_behave_like 'a jaeger component', job_name
  it_should_behave_like 'a collector', job_name
  it_should_behave_like 'an elasticsearch connected component', job_name
  it_should_behave_like 'a processor', job_name
  it_should_behave_like 'a queryable component', job_name

  it 'uses the correct admin port' do
    args = get_process_from_bpm(YAML::load(template.render(config)), job_name)['args']
    expect(args).to include '--admin-http-port=14269'
  end

  it 'only allows supported span_storage_types' do
    expect{ template.render({'span_storage_type' => 'memory'}) }.not_to raise_error
    expect{ template.render({'span_storage_type' => 'badger'}) }.not_to raise_error
    expect{ template.render({'span_storage_type' => 'elasticsearch', 'es' => { 'server-urls' => ['foo']}}) }.not_to raise_error
    expect{ template.render({'span_storage_type' => 'foo'}) }.to raise_error('foo is not a supported span_storage_type for jaeger-all-in-one')
  end

  it 'sets memory storage type flags' do
    config = { 'span_storage_type' => 'memory', 'memory' => { 'max-traces' => 10 } }
    args = get_process_from_bpm(YAML::load(template.render config), job_name)['args']
    expect(args).to include '--memory.max-traces=10'
  end

  describe 'badger storage type' do
    let(:config) { { 'span_storage_type' => 'badger' } }
    it 'creates additional volumes' do
      process = get_process_from_bpm(YAML::load(template.render config), job_name)
      expect(process['additional_volumes']).to include({'path' => '/var/vcap/store/jaeger-all-in-one/keys', 'writable' => true })
      expect(process['additional_volumes']).to include({ 'path' => '/var/vcap/store/jaeger-all-in-one/values', 'writable' => true })
    end

    it 'sets badger CLI flags' do
      args = get_process_from_bpm(YAML::load(template.render config), job_name)['args']
      expect(args).to include '--badger.ephemeral=false'
      expect(args).to include '--badger.directory-key=/var/vcap/store/jaeger-all-in-one/keys'
      expect(args).to include '--badger.directory-value=/var/vcap/store/jaeger-all-in-one/values'
      expect(args).to include '--badger.consistency=false'
      expect(args).to include '--badger.maintenance-interval=5m0s'
      expect(args).to include '--badger.metrics-update-interval=10s'
      expect(args).to include '--badger.read-only=false'
      expect(args).to include '--badger.span-store-ttl=72h0m0s'
      expect(args).to include '--badger.truncate=false'
    end
  end
end