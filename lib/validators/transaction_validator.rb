# frozen_string_literal: true

class TransactionValidator
  class << self
    def amount_valid?(card, amount, tax)
      (card.balance - amount - tax).positive?
    end

    def tax_valid?(amount, tax)
      amount >= tax
    end
  end
end
