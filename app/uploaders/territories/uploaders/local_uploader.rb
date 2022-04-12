# frozen_string_literal: true

require 'digest/sha1'

module Territories
  module Uploaders
    class LocalUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick

      storage :file

      def store_dir
        "uploads/#{env_dir}#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end

      private

      def env_dir
        [
          Rails.application.class.module_parent.name.underscore,
          Rails.env.production? ? nil : Rails.env.to_s,
          ''
        ].compact.join('/')
      end

      process resize_to_fit: [2880, 1920] # 3x2

      version :big do
        process resize_to_fill: [1440, 960]
      end

      version :medium do
        process resize_to_fill: [720, 480]
      end

      version :small do
        process resize_to_fill: [360, 240]
      end

      version :thumb do
        process resize_to_fill: [180, 120]
      end

      def extension_allowlist
        %w[jpg jpeg gif png]
      end

      def filename
        if original_filename
          Digest::SHA1.hexdigest(original_filename)
        end
      end
    end
  end
end
