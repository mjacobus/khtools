# frozen_string_literal: true

module Territories
  class TerritoryPendingVerificationComponent < RecordAttributeComponent
    private

    def value
      t(record.pending_verification.to_s) if record.pending_verification
    end

    def icon_name
      'exclamation-diamond'
    end
  end
end
