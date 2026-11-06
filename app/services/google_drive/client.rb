# frozen_string_literal: true

module GoogleDrive
  # Minimal Drive v3 client using a stored OAuth refresh token.
  class Client
    class Error < StandardError; end

    TOKEN_URL = 'https://oauth2.googleapis.com/token'
    FILES_URL = 'https://www.googleapis.com/drive/v3/files'
    UPLOAD_URL = 'https://www.googleapis.com/upload/drive/v3/files' \
                 '?uploadType=multipart&fields=id,webViewLink&supportsAllDrives=true'
    FOLDER = 'application/vnd.google-apps.folder'

    def self.exchange_code(code:, redirect_uri:, client_id:, client_secret:)
      new(refresh_token: nil, client_id:, client_secret:)
        .token(grant_type: 'authorization_code', code:, redirect_uri:).fetch('refresh_token')
    end

    def initialize(refresh_token:, client_id:, client_secret:)
      @refresh_token = refresh_token
      @client_id = client_id
      @client_secret = client_secret
    end

    def access_token
      if @access_token && Time.current < @expires_at
        return @access_token
      end

      body = token(grant_type: 'refresh_token', refresh_token: @refresh_token)
      @expires_at = Time.current + body.fetch('expires_in').to_i.seconds - 1.minute
      @access_token = body.fetch('access_token')
    end

    def token(**params)
      post = Net::HTTP::Post.new(URI(TOKEN_URL))
      post.set_form_data(params.merge(client_id: @client_id, client_secret: @client_secret))
      request(post, authorize: false)
    end

    def find_folder(name:, parent_id:)
      find(name, parent_id, "mimeType = '#{FOLDER}'")
    end

    def find_file(name:, parent_id:)
      find(name, parent_id, "mimeType != '#{FOLDER}'")
    end

    def create_folder(name:, parent_id:)
      post = Net::HTTP::Post.new(URI("#{FILES_URL}?fields=id&supportsAllDrives=true"))
      post.content_type = 'application/json'
      post.body = { name:, parents: [parent_id], mimeType: FOLDER }.to_json
      request(post).fetch('id')
    end

    def upload(path:, name:, parent_id:, mime_type:, description:, app_properties:) # rubocop:disable Metrics/ParameterLists
      metadata = { name:, parents: [parent_id], description:,
                   appProperties: app_properties.compact.transform_values(&:to_s) }
      boundary = "khtools-#{SecureRandom.hex(12)}"
      post = Net::HTTP::Post.new(URI(UPLOAD_URL))
      post.content_type = "multipart/related; boundary=#{boundary}"
      post.body = multipart(boundary, metadata, mime_type, File.binread(path))
      body = request(post)
      { id: body.fetch('id'), web_view_link: body['webViewLink'] }
    end

    private

    def find(name, parent_id, type_condition)
      query = "name = '#{escape(name)}' and '#{escape(parent_id)}' in parents " \
              "and #{type_condition} and trashed = false"
      params = URI.encode_www_form(q: query, fields: 'files(id)', supportsAllDrives: true,
                                   includeItemsFromAllDrives: true)
      files = request(Net::HTTP::Get.new(URI("#{FILES_URL}?#{params}"))).fetch('files')
      files.first&.fetch('id')
    end

    def escape(value)
      value.to_s.gsub('\\') { '\\\\' }.gsub("'") { "\\'" }
    end

    def multipart(boundary, metadata, mime_type, bytes)
      json = "Content-Type: application/json; charset=UTF-8\r\n\r\n#{metadata.to_json}\r\n"
      "--#{boundary}\r\n#{json}".b +
        "--#{boundary}\r\nContent-Type: #{mime_type}\r\n\r\n".b + bytes.b + "\r\n--#{boundary}--".b
    end

    def request(http_request, authorize: true)
      http_request['Authorization'] = "Bearer #{access_token}" if authorize
      uri = http_request.uri
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(http_request)
      end
      if response.code.start_with?('2')
        return JSON.parse(response.body)
      end

      raise Error, "Drive HTTP #{response.code}: #{response.body.to_s[0, 300]}"
    end
  end
end
