# frozen_string_literal: true

module TerritoryUploaderConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def file_uploader
      if Rails.env.production?
        return Territories::Uploaders::CloudinaryUploader
      end

      if ENV['FORCE_CLOUDINARY_UPLOADER'] # rubocop:disable Rails/EnvironmentVariableAccess
        return Territories::Uploaders::CloudinaryUploader
      end

      Territories::Uploaders::LocalUploader
    end
  end
end
