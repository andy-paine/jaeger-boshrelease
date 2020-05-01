
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

  describe 'es tags-as-fields config file' do
    let(:template) { job.template('config/es/tags-as-fields.txt') }
    it 'creates an empty file when no config is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the file with each key on a new line' do
      config = { 'es' => { 'tags-as-fields' => { 'tags' => ['foo', 'bar'] }}}
      expect(template.render(config)).to eq(<<~EOF
      foo
      bar
      EOF
      )
    end
  end

  describe 'es token file' do
    let(:template) { job.template('config/es/token.txt') }
    it 'creates an empty file when no config is provided' do
      expect(template.render({})).to eq('')
    end

    it 'populates the file with token' do
      config = { 'es' => { 'token-file' => 'test-token' }}
      expect(template.render(config)).to eq('test-token')
    end
  end
end