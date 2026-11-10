# frozen_string_literal: true

module Finance
  # The fields typed on the edit page, money included: an S-24 has its worldwide work and local
  # donations, and its total is their sum.
  module DocumentValues
    MONEY_FIELDS = { amount: :amount_cents, worldwide: :worldwide_cents,
                     congregation: :congregation_cents }.freeze

    private

    def assign_and_validate
      fields = params.require(:document).permit(:kind, :competence, :document_date, :description,
                                                *MONEY_FIELDS.keys)
      @document.assign_attributes(fields.except(*MONEY_FIELDS.keys))
      invalid = assign_money(fields.slice(*MONEY_FIELDS.keys).to_h)
      valid = @document.valid?
      invalid.each { |text| @document.errors.add(:base, "Valor inválido: #{text}") }
      valid && invalid.empty?
    end

    # Returns what was typed and is not money.
    def assign_money(texts)
      texts.each { |field, text| @document[MONEY_FIELDS.fetch(field.to_sym)] = Money.parse(text:) }
      add_up_s24
      texts.values.select { |text| text.present? && Money.parse(text:).nil? }
    end

    # An S-24's total is its worldwide work plus local donations.
    def add_up_s24
      if @document.kind == 's24' && (@document.worldwide_cents || @document.congregation_cents)
        @document.amount_cents = @document.worldwide_cents.to_i + @document.congregation_cents.to_i
      end
    end
  end
end
