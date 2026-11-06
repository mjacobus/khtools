# frozen_string_literal: true

require 'open3'

module Finance
  module Pdf
    class Error < StandardError; end
    class PasswordError < Error; end

    module_function

    def text(path:, password: nil)
      args = ['pdftotext', '-layout']
      args += ['-upw', password] if password
      run(*args, path, '-')
    end

    def encrypted?(path:)
      _out, _err, status = Open3.capture3('qpdf', '--is-encrypted', path)
      status.exitstatus.zero?
    end

    def decrypt(path:, password:, output:)
      run('qpdf', "--password=#{password}", '--decrypt', path, output)
      output
    end

    def run(*args)
      out, err, status = Open3.capture3(*args)
      # qpdf exits 3 for warnings with a usable result
      if status.success? || (args.first == 'qpdf' && status.exitstatus == 3)
        return out
      end
      if err.match?(/password/i)
        raise PasswordError, err.strip
      end

      raise Error, err.strip.presence || "#{args.first} failed"
    end
  end
end
