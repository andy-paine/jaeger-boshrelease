
require 'rspec'
require 'bosh/template/test'

describe 'jaeger-all-in-one config files' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }

  describe 'ui config file' do
    let(:template) { job.template('config/ui.json') }
    it 'creates an empty file when no config is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the file with the config provided' do
      config = { 'query' => { 'ui-config' => { 'some' => 'json' }}}
      expect(template.render(config)).to eq('{"some":"json"}')
    end
  end

  describe 'sampling strategies config file' do
    let(:template) { job.template('config/sampling-strategies.json') }
    it 'creates an empty file when no config is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the file with the config provided' do
      config = { 'sampling' => { 'strategies-file' => { 'some' => 'json' }}}
      expect(template.render(config)).to eq('{"some":"json"}')
    end
  end
end