# frozen_string_literal: true

module Congregation
  module Publishers
    class PublisherPrivilegeComponent < RecordAttributeComponent
      private

      def value
        record.privileges.map { |privilege| attribute_name(record, privilege) }.join(', ')
      end

      def icon_name
        'award'
      end
    end
  end
end
