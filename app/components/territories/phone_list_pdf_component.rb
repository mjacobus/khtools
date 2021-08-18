# frozen_string_literal: true

module Territories
  class PhoneListPdfComponent < ApplicationComponent
    has :territory

    def page_break
      '<p style="page-break-after:always;"></p>'.html_safe
    end

    def phone_numbers_in_groups
      phone_numbers.in_groups_of(per_page)
    end

    def last_index
      (phone_numbers.size.to_f / per_page).ceil - 1
    end

    private

    def per_page
      34
    end

    def phone_numbers
      @phone_numbers ||= territory.phone_numbers
    end
  end
end
