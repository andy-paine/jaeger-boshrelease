require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

['jaeger-all-in-one', 'jaeger-collector', 'jaeger-query', 'jaeger-agent'].each do |job_name|
  describe "#{job_name}: common configuration" do
    let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
    let(:job) { release.job(job_name) }
    let(:template) { job.template('config/bpm.yml') }
    let(:config) { get_default_config job_name }

    it 'should set sensible defaults' do
      args = get_process_from_bpm(YAML::load(template.render config), job_name)['args']
      expect(args).to include '--admin-http-port=14269'
      expect(args).to include '--log-level=info'
      expect(args).to include '--metrics-backend=prometheus'
      expect(args).to include '--metrics-http-route=/metrics'
    end
  end
end