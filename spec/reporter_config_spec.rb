require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

describe 'jaeger-all-in-one: reporter configuration' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }

  describe 'bpm.yml' do
    let(:template) { job.template('config/bpm.yml') }

    it 'should set sensible defaults' do
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
      expect(args).to include '--reporter.grpc.tls.cert=/var/vcap/jobs/jaeger-all-in-one/tls/reporter.grpc.tls.cert.pem'
      expect(args).to include '--reporter.grpc.tls.key=/var/vcap/jobs/jaeger-all-in-one/tls/reporter.grpc.tls.key.pem'
    end

    it 'should include grpc ca cert when provided' do
      config['reporter']['grpc']['tls']['ca'] = '--- BEGIN CERT ---'
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--reporter.grpc.tls.ca=/var/vcap/jobs/jaeger-all-in-one/tls/reporter.grpc.tls.ca.pem'
    end

    it 'should include set grpc server name when provided' do
      config['reporter']['grpc']['tls']['server-name'] = 'example.com'
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--reporter.grpc.tls.server-name=example.com'
    end

    it 'should provide grpc host-ports as comma separated list' do
      config = { 'reporter' => { 'grpc' => { 'host-port' => ['host1:port1', 'host2:port2'] }}}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--reporter.grpc.host-port=host1:port1,host2:port2'
    end
  end

  describe 'tls files' do
    describe 'grpc tls key' do
      let(:template) { job.template('tls/reporter.grpc.tls.key.pem') }
      it 'creates an empty file when no private key is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the private key provided' do
        config = { 'reporter' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN KEY ---')
      end
    end

    describe 'grpc tls cert' do
      let(:template) { job.template('tls/reporter.grpc.tls.cert.pem') }
      it 'creates an empty file when no certificate is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the certificate provided' do
        config = { 'reporter' => { 'grpc' => { 'tls' => { 'certificate' => '--- BEGIN CERT ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN CERT ---')
      end
    end

    describe 'grpc client ca cert' do
      let(:template) { job.template('tls/reporter.grpc.tls.ca.pem') }
      it 'creates an empty file when no certificate is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the certificate provided' do
        config = { 'reporter' => { 'grpc' => { 'tls' => { 'ca' => '--- BEGIN CERT ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN CERT ---')
      end
    end
  end
end