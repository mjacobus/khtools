# frozen_string_literal: true

require 'digest/sha1'

module Territories
  module Uploaders
    class LocalUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick
      include Common

      storage :file

      def store_dir
        "uploads/#{env_dir}/#{mounted_as}/#{model.id}"
      end
    end
  end
end
