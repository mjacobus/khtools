# frozen_string_literal: true

module Db::Identifiable
  AmbiguousRecordError = Class.new(StandardError)
  NotFoundError = Class.new(ActiveRecord::RecordNotFound)

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def identifiable_by(*args)
      @identifiable_by_fields = args
    end

    # rubocop:disable Metrics/MethodLength
    def identify(term)
      found = find_by(id: term)

      if found
        return found
      end

      @identifiable_by_fields.each do |_field|
        query = where('name ILIKE ?', "#{term}%").limit(2)
        count = query.count

        if count > 1
          raise AmbiguousRecordError, "More than one #{self} matches '#{term}'"
        end

        if count.positive?
          return query.first
        end
      end

      raise NotFoundError, "No #{self} matches '#{term}'"
    end
    # rubocop:enable Metrics/MethodLength
  end
end
