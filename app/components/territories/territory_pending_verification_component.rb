# frozen_string_literal: true

module Territories
  class TerritoryPendingVerificationComponent < RecordAttributeComponent
    private

    def value
      if record.pending_verification
        t(record.pending_verification.to_s)
      end
    end

    def icon_name
      'exclamation-diamond'
    end
  end
end
