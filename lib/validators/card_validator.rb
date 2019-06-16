# frozen_string_literal: true

class CardValidator
  class << self
    def cards_available?(account)
      account.cards.any?
    end

    def valid_card_index?(cards_size, card_index)
      card_index <= cards_size && card_index.positive?
    end
  end
end
