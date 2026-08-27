# frozen_string_literal: true

require 'rails_helper'
require 'rack/test'
require 'omniauth-google-oauth2'

# Drives the real OmniAuth callback phase end to end:
#
#   OmniAuth::Strategies::GoogleOauth2 -> omniauth-oauth2 -> oauth2 -> faraday
#
# and back through jwt for the id_token. Only the network is faked, via a
# Faraday test adapter injected through client_options[:connection_build].
#
# This exists because faraday and jwt both crossed a major version on this
# path while sessions_controller_spec stubs UserSessionService entirely, so
# nothing else in the suite would notice the stack breaking.
RSpec.describe 'Google OAuth login' do
  include Rack::Test::Methods

  let(:skip_login) { true }
  let(:auth_hash) do
    complete_callback_phase
    JSON.parse(last_response.body)
  end
  let(:client_id) { 'client-id.apps.googleusercontent.com' }

  let(:id_token_claims) do
    {
      'iss' => 'https://accounts.google.com',
      'aud' => client_id,
      'sub' => '1234567890',
      'email' => 'marcelo@example.com',
      'exp' => Time.now.to_i + 3600,
      'iat' => Time.now.to_i
    }
  end

  let(:id_token) { JWT.encode(id_token_claims, 'unused-google-signing-key', 'HS256') }

  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('https://oauth2.googleapis.com/token') do
        [200, { 'Content-Type' => 'application/json' }, {
          access_token: 'access-token-123',
          token_type: 'Bearer',
          expires_in: 3599,
          id_token:
        }.to_json]
      end

      stub.get('https://www.googleapis.com/oauth2/v3/userinfo') do
        [200, { 'Content-Type' => 'application/json' }, {
          sub: '1234567890',
          name: 'Marcelo Jacobus',
          email: 'marcelo@example.com',
          email_verified: true,
          picture: 'https://lh3.googleusercontent.com/photo.jpg'
        }.to_json]
      end
    end
  end

  let(:app) do
    connection_build = ->(builder) { builder.adapter(:test, stubs) }
    id = client_id

    Rack::Builder.new do
      use Rack::Session::Cookie, secret: 'a' * 64
      use OmniAuth::Builder do
        provider(:google_oauth2, id, 'client-secret',
                 client_options: { connection_build: })
      end
      run lambda { |env|
            [200, { 'Content-Type' => 'application/json' }, [env['omniauth.auth'].to_json]]
          }
    end
  end

  # Walks the request phase first so the callback carries the state omniauth
  # itself generated, rather than one forced into the session.
  def complete_callback_phase
    get('/auth/google_oauth2')
    state = CGI.parse(URI.parse(last_response.headers['Location']).query).fetch('state').first

    get("/auth/google_oauth2/callback?code=the-code&state=#{state}")
  end

  it 'completes the callback phase' do
    expect(auth_hash['provider']).to eq('google_oauth2')
  end

  it 'reads the uid from the userinfo endpoint' do
    expect(auth_hash['uid']).to eq('1234567890')
  end

  it 'reads the email from the userinfo endpoint' do
    expect(auth_hash.dig('info', 'email')).to eq('marcelo@example.com')
  end

  it 'decodes the id_token into extra.id_info' do
    expect(auth_hash.dig('extra', 'id_info', 'email')).to eq('marcelo@example.com')
  end

  context 'when the id_token was issued for a different audience' do
    let(:id_token_claims) { super().merge('aud' => 'someone-elses-client-id') }

    it 'rejects the token' do
      expect { complete_callback_phase }.to raise_error(JWT::InvalidAudError)
    end
  end
end
