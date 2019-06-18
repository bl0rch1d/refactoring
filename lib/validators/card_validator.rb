# frozen_string_literal: true

class CardValidator
  class << self
    def cards_available?(account)
      account.cards.any?
    end

    def valid_card_index?(cards_size, card_index)
      card_index <= cards_size && card_index.positive?
    end

    def card_number_valid?(value)
      value.size == Cards::Base::NUMBER_LENGTH
    end

    def card_type_valid?(type)
      Cards.constants.include? type.intern.capitalize
    end
  end
end
