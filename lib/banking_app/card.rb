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

    def add(account:, type:)
      account.cards <<= new(TEMPLATES[type])
    end

    def destroy(account, card_index)
      account.cards.delete_at(card_index)
    end
  end
end
