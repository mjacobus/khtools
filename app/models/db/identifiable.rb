# frozen_string_literal: true

module Db
  module Identifiable
    AmbiguousRecordError = Class.new(StandardError)
    NotFoundError = Class.new(ActiveRecord::RecordNotFound)

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def identifiable_by(*args)
        @identifiable_by_fields = args
      end

      def identify(term)
        found = find_by(id: term)

        return found if found

        @identifiable_by_fields.each do |_field|
          query = where('name ILIKE ?', "#{term}%").limit(2)
          count = query.count

          raise AmbiguousRecordError, "More than one #{self} matches '#{term}'" if count > 1

          return query.first if count.positive?
        end

        raise NotFoundError, "No #{self} matches '#{term}'"
      end
    end
  end
end
