# frozen_string_literal: true

module GoogleDrive
  # Minimal Drive v3 client using a stored OAuth refresh token.
  class Client # rubocop:disable Metrics/ClassLength -- OAuth, lookup, folders, uploads
    class Error < StandardError; end

    TOKEN_URL = 'https://oauth2.googleapis.com/token'
    FILES_URL = 'https://www.googleapis.com/drive/v3/files'
    UPLOAD_BASE = 'https://www.googleapis.com/upload/drive/v3/files'
    # Every version is kept forever: Drive purges unpinned old versions after 30 days, and a
    # replaced monthly file must keep the version it replaced.
    UPLOAD_QUERY = 'uploadType=multipart&fields=id,webViewLink&supportsAllDrives=true' \
                   '&keepRevisionForever=true'
    UPLOAD_URL = "#{UPLOAD_BASE}?#{UPLOAD_QUERY}".freeze
    FOLDER = 'application/vnd.google-apps.folder'

    def initialize(client_id:, client_secret:, refresh_token: nil)
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

    def exchange_code(code:, redirect_uri:)
      token(grant_type: 'authorization_code', code:, redirect_uri:).fetch('refresh_token')
    end

    def find_folder(name:, parent_id:)
      find(name, parent_id, "mimeType = '#{FOLDER}'")
    end

    def find_file(name:, parent_id:)
      find(name, parent_id, "mimeType != '#{FOLDER}'")
    end

    # Tags are appProperties: only this app sees them, and they survive renames and moves.
    def find_tagged_folder(tags:)
      conditions = tags.map do |key, value|
        "appProperties has { key='#{escape(key)}' and value='#{escape(value)}' }"
      end
      query(conditions + ["mimeType = '#{FOLDER}'", 'trashed = false'])
    end

    def create_folder(name:, parent_id:, tags: {})
      metadata = { name:, parents: [parent_id], mimeType: FOLDER, appProperties: tags.presence }
      json_request(Net::HTTP::Post, FILES_URL, metadata.compact).fetch('id')
    end

    def children(parent_id:)
      pages = [children_page(parent_id, nil)]
      while (token = pages.last['nextPageToken'])
        pages << children_page(parent_id, token)
      end
      pages.flat_map { |page| page.fetch('files') }.map { |file| child(file) }
    end

    def tag(id:, tags:)
      json_request(Net::HTTP::Patch, "#{FILES_URL}/#{id}", { appProperties: tags })
    end

    def upload(path:, name:, parent_id:, mime_type:, description:, app_properties:) # rubocop:disable Metrics/ParameterLists
      metadata = { name:, parents: [parent_id], description:,
                   appProperties: app_properties.compact.transform_values(&:to_s) }
      send_file(Net::HTTP::Post.new(URI(UPLOAD_URL)), metadata, mime_type, path)
    end

    # New version of the same file (same id and link); the old one stays in its history.
    def update_file(id:, path:, mime_type:, description:, app_properties:)
      metadata = { description:, appProperties: app_properties.compact.transform_values(&:to_s) }
      patch = Net::HTTP::Patch.new(URI("#{UPLOAD_BASE}/#{id}?#{UPLOAD_QUERY}"))
      send_file(patch, metadata, mime_type, path)
    end

    private

    def send_file(http_request, metadata, mime_type, path)
      boundary = "khtools-#{SecureRandom.hex(12)}"
      http_request.content_type = "multipart/related; boundary=#{boundary}"
      http_request.body = multipart(boundary, metadata, mime_type, File.binread(path))
      body = request(http_request)
      { id: body.fetch('id'), web_view_link: body['webViewLink'] }
    end

    def json_request(http_class, url, body)
      http_request = http_class.new(URI("#{url}?fields=id&supportsAllDrives=true"))
      http_request.content_type = 'application/json'
      http_request.body = body.to_json
      request(http_request)
    end

    def token(**params)
      post = Net::HTTP::Post.new(URI(TOKEN_URL))
      post.set_form_data(params.merge(client_id: @client_id, client_secret: @client_secret))
      request(post, authorize: false)
    end

    def find(name, parent_id, type_condition)
      query(["name = '#{escape(name)}'", "'#{escape(parent_id)}' in parents", type_condition,
             'trashed = false'])
    end

    def query(conditions)
      params = URI.encode_www_form(q: conditions.join(' and '), fields: 'files(id)',
                                   supportsAllDrives: true, includeItemsFromAllDrives: true)
      files = request(Net::HTTP::Get.new(URI("#{FILES_URL}?#{params}"))).fetch('files')
      files.first&.fetch('id')
    end

    def children_page(parent_id, token)
      params = URI.encode_www_form(
        { q: "'#{escape(parent_id)}' in parents and trashed = false", pageSize: 1000,
          fields: 'nextPageToken,files(id,name,mimeType,sha256Checksum,webViewLink)',
          pageToken: token, supportsAllDrives: true, includeItemsFromAllDrives: true }.compact
      )
      request(Net::HTTP::Get.new(URI("#{FILES_URL}?#{params}")))
    end

    def child(file)
      { id: file['id'], name: file['name'], mime_type: file['mimeType'],
        folder: file['mimeType'] == FOLDER, sha256: file['sha256Checksum'],
        web_view_link: file['webViewLink'] }
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
