# frozen_string_literal: true

module TerritoryUploaderConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def file_uploader
      if Rails.env.test?
        return Territories::Uploaders::LocalUploader
      end

      if Rails.env.production?
        return Territories::Uploaders::CloudinaryUploader
      end

      if ENV['FORCE_CLOUDINARY_UPLOADER']
        return Territories::Uploaders::CloudinaryUploader
      end

      Territories::Uploaders::LocalUploader
    end
  end
end
