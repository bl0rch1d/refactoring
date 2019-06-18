# frozen_string_literal: true

module Cards
  class Base
    NUMBER_LENGTH = 16

    attr_accessor :balance
    attr_reader :number, :taxes

    def initialize(_balance)
      @number = self.class.generate_number
    end

    def self.add(account:, type:)
      account.cards <<= Cards.const_get(type.capitalize).new
    end

    def self.destroy(account, card_index)
      account.cards.delete_at(card_index)
    end

    def self.generate_number
      Array.new(NUMBER_LENGTH) { rand(10) }.join
    end
  end
end
