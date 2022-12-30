# frozen_string_literal: true

module Territories
  module Uploaders
    class CloudinaryUploader < CarrierWave::Uploader::Base
      include Cloudinary::CarrierWave
      include Common

      process :attach_credentials

      def attach_credentials
        {
          cloud_name: model.account.cloudinary_cloud_name,
          api_key: model.account.cloudinary_api_key,
          api_secret: model.account.cloudinary_api_secret,
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
