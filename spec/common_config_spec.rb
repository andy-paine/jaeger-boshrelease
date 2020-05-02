require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

['jaeger-all-in-one', 'jaeger-collector', 'jaeger-query', 'jaeger-agent'].each do |job_name|
  describe "#{job_name}: common configuration" do
    let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
    let(:job) { release.job(job_name) }
    let(:template) { job.template('config/bpm.yml') }
    let(:config) {
      case job_name
      when 'jaeger-all-in-one', 'jaeger-agent'
        {}
      when 'jaeger-collector', 'jaeger-query'
        {'span_storage_type' => 'elasticsearch', 'es' => { 'server-urls' => ['http://10.0.0.1:9200', 'http://10.0.0.2:9200']}}
      end
    }

    it 'should set sensible defaults' do
      args = get_process_from_bpm(YAML::load(template.render config), job_name)['args']
      expect(args).to include '--admin-http-port=14269'
      expect(args).to include '--downsampling.ratio=1.0'
      expect(args).to include '--http-server.host-port=:5778'
      expect(args).to include '--log-level=info'
      expect(args).to include '--metrics-backend=prometheus'
      expect(args).to include '--metrics-http-route=/metrics'

      expect(args).to_not include '--downsampling.hashsalt'
    end

    it 'should include downsampling hashsalt when provided' do
      config['downsampling'] = { 'hashsalt' => 'foo' }
      args = get_process_from_bpm(YAML::load(template.render config), job_name)['args']
      expect(args).to include '--downsampling.hashsalt=foo'
    end
  end
end