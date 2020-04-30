require 'rspec'
require 'bosh/template/test'

describe 'jaeger-all-in-one tls files' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }

  describe 'grpc tls key' do
    let(:template) { job.template('tls/grpc.key') }
    it 'creates an empty file when no private key is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the key file with the private key provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---'}}}}
      expect(template.render(config)).to eq('--- BEGIN KEY ---')
    end
  end

  describe 'grpc tls cert' do
    let(:template) { job.template('tls/grpc.crt') }
    it 'creates an empty file when no certificate is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the key file with the certificate provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'certificate' => '--- BEGIN CERT ---'}}}}
      expect(template.render(config)).to eq('--- BEGIN CERT ---')
    end
  end

  describe 'grpc client ca cert' do
    let(:template) { job.template('tls/grpc-client-ca.crt') }
    it 'creates an empty file when no certificate is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the key file with the certificate provided' do
      config = { 'collector' => { 'grpc' => { 'tls' => { 'client-ca' => '--- BEGIN CERT ---'}}}}
      expect(template.render(config)).to eq('--- BEGIN CERT ---')
    end
  end

  describe 'reporter tls configuration' do
    describe 'grpc tls key' do
      let(:template) { job.template('tls/reporter/grpc.key') }
      it 'creates an empty file when no private key is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the private key provided' do
        config = { 'reporter' => { 'grpc' => { 'tls' => { 'private_key' => '--- BEGIN KEY ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN KEY ---')
      end
    end

    describe 'grpc tls cert' do
      let(:template) { job.template('tls/reporter/grpc.crt') }
      it 'creates an empty file when no certificate is provided' do
        expect(template.render({})).to eq('')
      end

      it 'populates the key file with the certificate provided' do
        config = { 'reporter' => { 'grpc' => { 'tls' => { 'certificate' => '--- BEGIN CERT ---'}}}}
        expect(template.render(config)).to eq('--- BEGIN CERT ---')
      end
    end

    describe 'grpc client ca cert' do
      let(:template) { job.template('tls/reporter/grpc-ca.crt') }
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