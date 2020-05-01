# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

describe 'jaeger-all-in-one bpm.yml' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }
  let(:template) { job.template('config/bpm.yml') }


  describe 'elasticsearch storage type' do
    let(:config) {
      {
        'span_storage_type' => 'elasticsearch',
        'es' => { 'server-urls' => ['http://10.0.0.1:9200', 'http://10.0.0.2:9200'] }
      }
    }
    it 'sets sensible defaults' do
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--es.bulk.actions=1000'
      expect(args).to include '--es.bulk.flush-interval=200ms'
      expect(args).to include '--es.bulk.size=5000000'
      expect(args).to include '--es.bulk.workers=1'
      expect(args).to include '--es.create-index-templates=true'
      expect(args).to include '--es.max-num-spans=10000'
      expect(args).to include '--es.max-span-age=72h0m0s'
      expect(args).to include '--es.num-replicas=1'
      expect(args).to include '--es.num-shards=5'
      expect(args).to include '--es.sniffer=false'
      expect(args).to include '--es.tags-as-fields.all=false'
      expect(args).to include '--es.timeout=0s'
      expect(args).to include '--es.tls.enabled=false'
      expect(args).to include '--es.tls.skip-host-verify=false'
      expect(args).to include '--es.use-aliases=false'
      expect(args).to include "--es.server-urls='http://10.0.0.1:9200,http://10.0.0.2:9200'"

      expect(args).to_not include '--es.index-prefix'
      expect(args).to_not include '--es.password'
      expect(args).to_not include '--es.tags-as-fields.config-file'
      expect(args).to_not include '--es.tags-as-fields.dot-replacement'
      expect(args).to_not include '--es.tls.ca'
      expect(args).to_not include '--es.tls.cert'
      expect(args).to_not include '--es.tls.key'
      expect(args).to_not include '--es.tls.server-name'
      expect(args).to_not include '--es.token-file'
      expect(args).to_not include '--es.username'
      expect(args).to_not include '--es.version'
    end

    it 'includes optional properties when specified' do
      config['es']['index-prefix'] = 'foo'
      config['es']['tags-as-fields'] = { 'dot-replacement' => '_' }
      config['es']['tls'] = { 'server-name' => 'node-1.elasticsearch.cluster' }
      config['es']['version'] = 7
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--es.index-prefix=foo'
      expect(args).to include '--es.tags-as-fields.dot-replacement=_'
      expect(args).to include '--es.tls.server-name=node-1.elasticsearch.cluster'
      expect(args).to include '--es.version=7'
    end

    it 'includes tls options when specified' do
      config['es']['tls'] = {
        'ca' => '--- BEGIN CERT ---',
        'certificate' => '--- BEGIN CERT ---',
        'private_key' => '--- BEGIN KEY ---',
      }
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include '--es.tls.ca=/var/vcap/jobs/jaeger-all-in-one/tls/es.tls.ca.pem'
      expect(args).to include '--es.tls.cert=/var/vcap/jobs/jaeger-all-in-one/tls/es.tls.cert.pem'
      expect(args).to include '--es.tls.key=/var/vcap/jobs/jaeger-all-in-one/tls/es.tls.key.pem'
    end

    it 'includes basic auth options when specified' do
      config['es']['username'] = 'test-user'
      config['es']['password'] = 'Password123'
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include "--es.username='test-user'"
      expect(args).to include "--es.password='Password123'"
    end

    it 'include config file options when specified' do
      config['es']['tags-as-fields'] = { 'tags' => ['foo', 'bar'] }
      config['es']['token-file'] = 'testtoken'
      args = get_process_from_bpm(YAML::load template.render(config))['args']
      expect(args).to include "--es.tags-as-fields.config-file=/var/vcap/jobs/jaeger-all-in-one/config/es/tags-as-fields.txt"
      expect(args).to include "--es.token-file=/var/vcap/jobs/jaeger-all-in-one/config/es/token.txt"
    end

    it 'uses a BOSH link where available' do
      es_link = Bosh::Template::Test::Link.new(
        name: 'elasticsearch',
        instances: (1..3).map { |i| Bosh::Template::Test::LinkInstance.new(address: "es-node-#{i}")},
        properties: {
          'elasticsearch' => {
            'port' => 9999
          }
        }
      )
      rendered = template.render({'span_storage_type' => 'elasticsearch'}, consumes: [es_link])
      args = get_process_from_bpm(YAML::load rendered)['args']
      expect(args).to include "--es.server-urls='http://es-node-1:9999,http://es-node-2:9999,http://es-node-3:9999'"
    end
  end
end