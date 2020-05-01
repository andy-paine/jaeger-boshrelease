require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

describe 'jaeger-all-in-one: query configuration' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }

  describe 'bpm.yml' do
    let(:template) { job.template('config/bpm.yml') }
    it 'should include optional query parameters when provided' do
      config = { 'query' => { 'additional-headers' => ['Header: One', 'Header: Two'], 'static-files' => '/foo' }}
      rendered = template.render(config)
      args = get_process_from_bpm(YAML::load rendered)['args']
      expect(args).to include '--query.static-files=/foo'
      # YAML::load is causing some marshalling issues so check the raw outputted file is correct
      expect(rendered).to include '--query.additional-headers="Header: One"'
      expect(rendered).to include '--query.additional-headers="Header: Two"'
    end

    it 'should include ui config when content is provided' do
      config = { 'query' => { 'ui-config' => '{ "some": "json" }' }}
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--query.ui-config=/var/vcap/jobs/jaeger-all-in-one/config/ui.json'
    end
  end

  describe 'ui.json' do
    let(:template) { job.template('config/ui.json') }
    it 'creates an empty file when no config is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the file with the config provided' do
      config = { 'query' => { 'ui-config' => { 'some' => 'json' }}}
      expect(template.render(config)).to eq('{"some":"json"}')
    end
  end
end