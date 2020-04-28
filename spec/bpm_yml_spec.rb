# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'bosh/template/test'
require_relative 'spec_helper.rb'

RSpec::Expectations.configuration.on_potential_false_positives = :nothing

describe 'jaeger-all-in-one bpm.yml' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../')) }
  let(:job) { release.job('jaeger-all-in-one') }
  let(:template) { job.template('config/bpm.yml') }

  describe 'storage types' do
    it 'only allows supported span_storage_types' do
      expect{ template.render({'span_storage_type' => 'memory'}) }.not_to raise_error
      expect{ template.render({'span_storage_type' => 'foo'}) }.to raise_error
    end
  end

  describe 'badger storage type' do
    let(:config) { { 'span_storage_type' => 'badger' } }
    it 'creates additional volumes' do
      process = get_process_from_bpm(YAML::load template.render(config))
      expect(process['additional_volumes']).to include({'path' => '/var/vcap/store/jaeger-all-in-one/keys', 'writable' => true })
      expect(process['additional_volumes']).to include({ 'path' => '/var/vcap/store/jaeger-all-in-one/values', 'writable' => true })
    end

    it 'sets badger CLI flags' do
      process = get_process_from_bpm(YAML::load template.render(config))
      expect(process['args']).to include '--badger.ephemeral=false'
      expect(process['args']).to include '--badger.directory-key=/var/vcap/store/jaeger-all-in-one/keys'
      expect(process['args']).to include '--badger.directory-value=/var/vcap/store/jaeger-all-in-one/values'
    end
  end
end
