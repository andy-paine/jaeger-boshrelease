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
    it 'sets sensible defaults' do
      config = { 'span_storage_type' => 'elasticsearch' }
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

      expect(args).to_not include '--es.index-prefix'
      expect(args).to_not include '--es.password'
      expect(args).to_not include '--es.server-urls'
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
  end
end