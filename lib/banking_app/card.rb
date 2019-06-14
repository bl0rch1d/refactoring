# frozen_string_literal: true

class Card
  attr_reader :type, :number
  attr_accessor :balance

  TEMPLATES = {
    usual: {
      type: 'usual',
      balance: 50
    },

    capitalist: {
      type: 'capitalist',
      balance: 100
    },

    virtual: {
      type: 'virtual',
      balance: 150
    }
  }.freeze

  def initialize(type:, balance:)
    @type = type
    @balance = balance
    @number = Array.new(16) { rand(10) }.join
  end

  class << self
    include UI

    def show(account)
      return puts "There is no active cards!\n" unless account.cards.any?

      account.cards.each { |card| puts "- #{card.number}, #{card.type}" }
    end

    def add(account:, type:)
      account.cards <<= new(TEMPLATES[type])
    end

    def destroy(account, card_index)
      account.cards.delete_at(card_index)
    end
  end

  class Validator
    class << self
      def cards_available?(account)
        account.cards.any?
      end

      def valid_card_index?(cards_size, card_index)
        card_index <= cards_size && card_index.positive?
      end
    end
  end
end
