require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

describe 'jaeger-all-in-one collector configuration' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }

  describe 'bpm.yml' do
    let(:template) { job.template('config/bpm.yml') }

    it 'should set sensible defaults' do
      args = get_process_from_bpm(YAML::load template.render({}))['args']
      expect(args).to include '--collector.grpc-port=14250'
      expect(args).to include '--collector.grpc.tls.enabled=false'
      expect(args).to include '--collector.http-port=14268'
      expect(args).to include '--collector.num-workers=50'
      expect(args).to include '--collector.port=14267'
      expect(args).to include '--collector.queue-size=2000'
      expect(args).to include '--collector.queue-size-memory=0'
      expect(args).to include '--collector.zipkin.http-port=0'
      expect(args).to include '--collector.zipkin.allowed-headers=content-type'
      expect(args).to include '--collector.zipkin.allowed-origins=*'

      expect(args).to_not include '--collector.tags'
      expect(args).to_not include '--collector.grpc.tls.cert'
      expect(args).to_not include '--collector.grpc.tls.key'
      expect(args).to_not include '--collector.grpc.tls.client-ca'
    end

    it 'should enable grpc tls when a key and certificate are provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---', 'certificate' => '--- BEGIN CERT ---' }}}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--collector.grpc.tls.enabled=true'
      expect(args).to include '--collector.grpc.tls.cert=/var/vcap/jobs/jaeger-all-in-one/tls/collector.grpc.tls.cert.pem'
      expect(args).to include '--collector.grpc.tls.key=/var/vcap/jobs/jaeger-all-in-one/tls/collector.grpc.tls.key.pem'
    end

    it 'should include grpc client-ca cert when provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'client-ca' => '--- BEGIN CERT ---' }}}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--collector.grpc.tls.client-ca=/var/vcap/jobs/jaeger-all-in-one/tls/collector.grpc.tls.client-ca.pem'
    end

    it 'should include tags as a comma separated list of key=value' do
      config = { 'collector' => { 'tags' => { 'key1' => 'value1', 'key2' => 'value2' }}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--collector.tags=key1=value1,key2=value2'
    end

    it 'should provide zipkin options as comma separated lists' do
      config = { 'collector' => { 'zipkin' => { 'allowed-headers' => ['header1', 'header2'], 'allowed-origins' => ['origin1', 'origin2'] }}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--collector.zipkin.allowed-headers=header1,header2'
      expect(args).to include '--collector.zipkin.allowed-origins=origin1,origin2'
    end
  end

  describe 'tls files' do
    describe 'grpc tls key' do
      let(:template) { job.template('tls/collector.grpc.tls.key.pem') }
      it 'creates an empty file when no private key is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the private key provided' do
        config = { 'collector' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN KEY ---')
      end
    end

    describe 'grpc tls cert' do
      let(:template) { job.template('tls/collector.grpc.tls.cert.pem') }
      it 'creates an empty file when no certificate is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the certificate provided' do
        config = { 'collector' => { 'grpc' => { 'tls' => { 'certificate' => '--- BEGIN CERT ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN CERT ---')
      end
    end

    describe 'grpc client ca cert' do
      let(:template) { job.template('tls/collector.grpc.tls.client-ca.pem') }
      it 'creates an empty file when no certificate is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the certificate provided' do
        config = { 'collector' => { 'grpc' => { 'tls' => { 'client-ca' => '--- BEGIN CERT ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN CERT ---')
      end
    end
  end
end