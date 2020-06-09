require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper'

shared_examples 'a processor' do |job_name|
  describe "#{job_name}: processor configuration" do
    let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
    let(:job) { release.job(job_name) }
    let(:template) { job.template('config/bpm.yml') }
    let(:config) { get_default_config job_name }

    it 'should set sensible defaults' do
      args = get_process_from_bpm(YAML::load(template.render(config)), job_name)['args']
      expect(args).to include '--http-server.host-port=0.0.0.0:5778'
      expect(args).to include '--processor.jaeger-binary.server-host-port=0.0.0.0:6832'
      expect(args).to include '--processor.jaeger-binary.server-max-packet-size=65000'
      expect(args).to include '--processor.jaeger-binary.server-queue-size=1000'
      expect(args).to include '--processor.jaeger-binary.workers=10'
      expect(args).to include '--processor.jaeger-compact.server-host-port=0.0.0.0:6831'
      expect(args).to include '--processor.jaeger-compact.server-max-packet-size=65000'
      expect(args).to include '--processor.jaeger-compact.server-queue-size=1000'
      expect(args).to include '--processor.jaeger-compact.workers=10'
      expect(args).to include '--processor.zipkin-compact.server-host-port=0.0.0.0:5775'
      expect(args).to include '--processor.zipkin-compact.server-max-packet-size=65000'
      expect(args).to include '--processor.zipkin-compact.server-queue-size=1000'
      expect(args).to include '--processor.zipkin-compact.workers=10'
    end
  end
end