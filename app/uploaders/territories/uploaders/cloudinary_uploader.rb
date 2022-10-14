# frozen_string_literal: true

module Territories
  module Uploaders
    class CloudinaryUploader < CarrierWave::Uploader::Base
      include Cloudinary::CarrierWave
      include Common

      process :attach_credentials

      def attach_credentials
        {
          cloud_name:  ENV['CLOUDINARY_CLOUD_NAME_TWO'],
          api_key: ENV['CLOUDINARY_API_KEY_TWO'],
          api_secret: ENV['CLOUDINARY_API_SECRET_TWO'],
        }
      end

      # Carrierwave can remove stale images when the public_id is consistent
      # accross edits
      def public_id
        "#{env_dir}/#{model.class.to_s.underscore.split('/').last}/#{model.id}"
      end
    end
  end
end
