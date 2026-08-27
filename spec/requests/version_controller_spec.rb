# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionController do
  describe 'GET /version' do
    it 'responds successfully without authentication' do
      get('/version')

      expect(response).to be_successful
    end

    it 'exposes the deployed version' do
      ENV['KAMAL_VERSION'] = 'abc123'

      get('/version')

      expect(response.parsed_body).to eq('version' => 'abc123', 'environment' => 'test')
    ensure
      ENV.delete('KAMAL_VERSION')
    end

    it 'reports an unknown version when it is not deployed by kamal' do
      get('/version')

      expect(response.parsed_body['version']).to eq('unknown')
    end
  end
end
