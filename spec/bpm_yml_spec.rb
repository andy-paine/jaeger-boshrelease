# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

describe 'jaeger-all-in-one bpm.yml' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }
  let(:template) { job.template('config/bpm.yml') }

  describe 'storage types' do
    it 'only allows supported span_storage_types' do
      expect{ template.render({'span_storage_type' => 'memory'}) }.not_to raise_error
      expect{ template.render({'span_storage_type' => 'foo'}) }.to raise_error(/Only .* are supported values for span_storage_type, not: foo/)
    end
  end

  describe 'badger storage type' do
    let(:config) { { 'span_storage_type' => 'badger' } }
    it 'creates additional volumes' do
      process = get_process_from_bpm(YAML::load template.render(config))
      expect(process['additional_volumes']).to include({'path' => '/var/vcap/store/jaeger-all-in-one/keys', 'writable' => true })
      expect(process['additional_volumes']).to include({ 'path' => '/var/vcap/store/jaeger-all-in-one/values', 'writable' => true })
    end

    it 'sets badger CLI flags' do
      args = get_process_from_bpm(YAML::load template.render(config))['args']
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

  describe 'collector configuration' do
    it 'should set sensible defaults for collector configuration' do
      args = get_process_from_bpm(YAML::load template.render({}))['args']
      expect(args).to include '--collector.grpc-port=14250'
      expect(args).to include '--collector.grpc.tls.enabled=false'
      expect(args).to include '--collector.http-port=14268'
      expect(args).to include '--collector.num-workers=50'
      expect(args).to include '--collector.port=14267'
      expect(args).to include '--collector.queue-size=2000'
      expect(args).to include '--collector.queue-size-memory=0'
      expect(args).to include '--collector.zipkin.http-port=0'
      expect(args).to include "--collector.zipkin.allowed-headers='content-type'"
      expect(args).to include "--collector.zipkin.allowed-origins='*'"

      expect(args).to_not include '--collector.tags'
      expect(args).to_not include '--collector.grpc.tls.cert'
      expect(args).to_not include '--collector.grpc.tls.key'
      expect(args).to_not include '--collector.grpc.tls.client-ca'
    end

    it 'should enable grpc tls when a key and certificate are provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---', 'certificate' => '--- BEGIN CERT ---' }}}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--collector.grpc.tls.enabled=true'
      expect(args).to include '--collector.grpc.tls.cert=/var/vcap/jobs/jaeger-all-in-one/tls/collector/grpc.crt'
      expect(args).to include '--collector.grpc.tls.key=/var/vcap/jobs/jaeger-all-in-one/tls/collector/grpc.key'
    end

    it 'should include grpc client-ca cert when provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'client-ca' => '--- BEGIN CERT ---' }}}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--collector.grpc.tls.client-ca=/var/vcap/jobs/jaeger-all-in-one/tls/collector/grpc-client-ca.crt'
    end

    it 'should include tags as a comma separated list of key=value' do
      config = { 'collector' => { 'tags' => { 'key1' => 'value1', 'key2' => 'value2' }}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include "--collector.tags='key1=value1,key2=value2'"
    end

    it 'should provide zipkin options as comma separated lists' do
      config = { 'collector' => { 'zipkin' => { 'allowed-headers' => ['header1', 'header2'], 'allowed-origins' => ['origin1', 'origin2'] }}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include "--collector.zipkin.allowed-headers='header1,header2'"
      expect(args).to include "--collector.zipkin.allowed-origins='origin1,origin2'"
    end
  end

  describe 'processor configuration' do
    it 'should set sensible defaults for processor configuration' do
      args = get_process_from_bpm(YAML::load template.render({}))['args']
      expect(args).to include '--processor.jaeger-binary.server-host-port=:6832'
      expect(args).to include '--processor.jaeger-binary.server-max-packet-size=65000'
      expect(args).to include '--processor.jaeger-binary.server-queue-size=1000'
      expect(args).to include '--processor.jaeger-binary.workers=10'
      expect(args).to include '--processor.jaeger-compact.server-host-port=:6831'
      expect(args).to include '--processor.jaeger-compact.server-max-packet-size=65000'
      expect(args).to include '--processor.jaeger-compact.server-queue-size=1000'
      expect(args).to include '--processor.jaeger-compact.workers=10'
      expect(args).to include '--processor.zipkin-compact.server-host-port=:5775'
      expect(args).to include '--processor.zipkin-compact.server-max-packet-size=65000'
      expect(args).to include '--processor.zipkin-compact.server-queue-size=1000'
      expect(args).to include '--processor.zipkin-compact.workers=10'
    end
  end

  describe 'reporter configuration' do
    it 'should set sensible defaults for reporter configuration' do
      args = get_process_from_bpm(YAML::load template.render({}))['args']
      expect(args).to include '--reporter.grpc.discovery.min-peers=3'
      expect(args).to include '--reporter.grpc.retry.max=3'
      expect(args).to include '--reporter.grpc.tls.enabled=false'
      expect(args).to include '--reporter.grpc.tls.skip-host-verify=false'

      expect(args).to_not include '--reporter.grpc.host-port'
      expect(args).to_not include '--reporter.grpc.tls.ca'
      expect(args).to_not include '--reporter.grpc.tls.cert'
      expect(args).to_not include '--reporter.grpc.tls.key'
      expect(args).to_not include '--reporter.grpc.tls.server-name'
    end

    let(:config) {
      { 'reporter' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---', 'certificate' => '--- BEGIN CERT ---' }}}}
    }

    it 'should enable grpc tls when a key and certificate are provided' do
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--reporter.grpc.tls.enabled=true'
      expect(args).to include '--reporter.grpc.tls.cert=/var/vcap/jobs/jaeger-all-in-one/tls/reporter/grpc.crt'
      expect(args).to include '--reporter.grpc.tls.key=/var/vcap/jobs/jaeger-all-in-one/tls/reporter/grpc.key'
    end

    it 'should include grpc ca cert when provided' do
      config['reporter']['grpc']['tls']['ca'] = '--- BEGIN CERT ---'
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--reporter.grpc.tls.ca=/var/vcap/jobs/jaeger-all-in-one/tls/reporter/grpc-ca.crt'
    end

    it 'should include set grpc server name when provided' do
      config['reporter']['grpc']['tls']['server-name'] = 'example.com'
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--reporter.grpc.tls.server-name=example.com'
    end

    it 'should provide grpc host-ports as comma separated list' do
      config = { 'reporter' => { 'grpc' => { 'host-port' => ['host1:port1', 'host2:port2'] }}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include "--reporter.grpc.host-port='host1:port1,host2:port2'"
    end
  end
end