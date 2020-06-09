require 'rspec'
require 'bosh/template/test'
require_relative '../spec_helper'
require_relative '../common_config'
require_relative '../processor_config'
require_relative '../reporter_config'

describe 'jaeger-agent' do
  job_name = 'jaeger-agent'
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job(job_name) }
  let(:template) { job.template('config/bpm.yml') }

  it_should_behave_like 'a jaeger component', job_name
  it_should_behave_like 'a processor', job_name
  it_should_behave_like 'a reporter', job_name

  it 'uses the correct admin port' do
    args = get_process_from_bpm(YAML::load(template.render({})), job_name)['args']
    expect(args).to include '--admin-http-port=14269'
  end
end