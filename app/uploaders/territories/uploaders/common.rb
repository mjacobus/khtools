# frozen_string_literal: true

module Territories
  module Uploaders
    module Common
      extend ActiveSupport::Concern

      included do
        unless respond_to?(:eager)
          def self.eager
            # NOOP - to be compatible with cloudinary
          end
        end

        process resize_to_fit: [2880, 1920] # 3x2

        version :big do
          eager # makes it work when dynamic transformations are disabled
          process resize_to_fit: [1440, 960]
        end

        version :medium do
          eager
          process resize_to_fit: [720, 480]
        end

        version :small do
          eager
          process resize_to_fit: [360, 240]
        end

        version :thumb do
          eager
          process resize_to_fit: [180, 120]
        end
      end

      def filename
        [Digest::SHA1.hexdigest(original_filename), file.extension].join('.') if original_filename
      end

      def extension_allowlist
        %w[jpg jpeg gif png]
      end

      private

      def env_dir
        [
          Rails.application.class.module_parent.name.underscore,
          Rails.env.production? ? nil : Rails.env.to_s,
          ''
        ].compact.join('/')
      end
    end
  end
end
