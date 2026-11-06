# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleDrive::Client do
  let(:client) do
    described_class.new(refresh_token: 'refresh', client_id: 'id', client_secret: 'secret')
  end
  let(:http) { instance_double(Net::HTTP) }
  let(:requests) { [] }
  let(:responses) { [] }

  before do
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request) do |request|
      requests << request
      responses.shift || response(200, access_token: 'access', expires_in: 3600)
    end
  end

  def response(code, body)
    instance_double(Net::HTTPResponse, code: code.to_s, body: body.to_json)
  end

  it 'exchanges the refresh token once and reuses the access token' do
    responses.push(response(200, access_token: 'access', expires_in: 3600),
                   response(200, files: []), response(200, files: []))

    2.times { client.find_folder(name: 'x', parent_id: 'root') }

    expect(requests.map(&:path).count { |path| path == '/token' }).to eq(1)
    expect(URI.decode_www_form(requests.first.body).to_h)
      .to include('grant_type' => 'refresh_token', 'refresh_token' => 'refresh',
                  'client_id' => 'id')
    expect(requests.last['Authorization']).to eq('Bearer access')
  end

  it 'finds a folder by name, escaping quotes' do
    responses.push(response(200, access_token: 'access', expires_in: 3600),
                   response(200, files: [{ id: 'F1' }]))

    expect(client.find_folder(name: "D'Arc", parent_id: 'P1')).to eq('F1')

    query = URI.decode_www_form(URI(requests.last.path).query).to_h['q']
    expect(query).to include("name = 'D\\'Arc'", "'P1' in parents",
                             "mimeType = 'application/vnd.google-apps.folder'", 'trashed = false')
  end

  it 'returns nil when nothing is found' do
    responses.push(response(200, access_token: 'a', expires_in: 3600), response(200, files: []))

    expect(client.find_file(name: 'x.pdf', parent_id: 'P1')).to be_nil
  end

  it 'creates folders' do
    responses.push(response(200, access_token: 'a', expires_in: 3600), response(200, id: 'NEW'))

    expect(client.create_folder(name: '2026-11', parent_id: 'P1')).to eq('NEW')
    expect(JSON.parse(requests.last.body))
      .to eq('name' => '2026-11', 'parents' => ['P1'],
             'mimeType' => 'application/vnd.google-apps.folder')
  end

  describe '#upload' do
    let(:result) do
      client.upload(path: upload_path, name: 'a.pdf', parent_id: 'P1', mime_type: 'application/pdf',
                    description: 'desc', app_properties: { kind: 'bill', amount_cents: 10 })
    end

    before do
      File.binwrite(upload_path, '%PDF-bytes')
      responses.push(response(200, access_token: 'a', expires_in: 3600),
                     response(200, id: 'FILE', webViewLink: 'https://drive/FILE'))
    end

    after { FileUtils.rm_f(upload_path) }

    def upload_path
      Rails.root.join('tmp/drive-upload-spec.pdf')
    end

    it 'returns the file id and link' do
      expect(result).to eq(id: 'FILE', web_view_link: 'https://drive/FILE')
    end

    it 'sends metadata and bytes in one multipart request' do
      result

      expect(requests.last.path).to start_with('/upload/drive/v3/files?uploadType=multipart')
      # a later replacement must not let Drive purge this first version after 30 days
      expect(requests.last.path).to include('keepRevisionForever=true')
      expect(requests.last.body).to include(
        '"name":"a.pdf"', '"parents":["P1"]', '"description":"desc"',
        '"appProperties":{"kind":"bill","amount_cents":"10"}', '%PDF-bytes'
      )
    end
  end

  describe '#update_file' do
    let(:result) do
      client.update_file(id: 'FILE', path: upload_path, mime_type: 'application/pdf',
                         description: 'desc', app_properties: { kind: 's26' })
    end

    before do
      File.binwrite(upload_path, '%PDF-new')
      responses.push(response(200, access_token: 'a', expires_in: 3600),
                     response(200, id: 'FILE', webViewLink: 'https://drive/FILE'))
    end

    after { FileUtils.rm_f(upload_path) }

    def upload_path
      Rails.root.join('tmp/drive-update-spec.pdf')
    end

    it 'uploads a new version of the same file, keeping the old one forever' do
      expect(result).to eq(id: 'FILE', web_view_link: 'https://drive/FILE')
      expect(requests.last).to be_a(Net::HTTP::Patch)
      expect(requests.last.path).to start_with('/upload/drive/v3/files/FILE?uploadType=multipart')
      expect(requests.last.path).to include('keepRevisionForever=true')
      expect(requests.last.body)
        .to include('"description":"desc"', '"appProperties":{"kind":"s26"}', '%PDF-new')
      expect(requests.last.body).not_to include('"parents"')
    end
  end

  it 'raises on HTTP errors' do
    responses.push(response(200, access_token: 'a', expires_in: 3600), response(404, error: 'nope'))

    expect do
      client.create_folder(name: 'x', parent_id: 'P1')
    end.to raise_error(described_class::Error, /404/)
  end

  it 'exchanges an authorization code for a refresh token' do
    responses.push(response(200, access_token: 'a', expires_in: 3600, refresh_token: 'R'))

    token = described_class.new(client_id: 'id', client_secret: 's')
      .exchange_code(code: 'C', redirect_uri: 'https://x/cb')

    expect(token).to eq('R')
    expect(URI.decode_www_form(requests.last.body).to_h)
      .to include('grant_type' => 'authorization_code', 'code' => 'C', 'redirect_uri' => 'https://x/cb')
  end
end
