# frozen_string_literal: true

require_relative 'ui'

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

    def show_cards_for(account)
      return puts "There is no active cards!\n" unless account.cards.any?

      account.cards.each { |card| puts "- #{card.number}, #{card.type}" }
    end

    def add(account:, type:)
      account.cards <<= new(TEMPLATES[type])
    end

    # def destroy(account)
    #   loop do
    #     break puts "There is no active cards!\n" unless account.cards.any?

    #     show_card_removing_menu(account.cards)

    #     reply = gets.strip

    #     break if reply == 'exit'

    #     return puts "You entered wrong number!\n" unless reply.to_i <= account.cards.length && reply.to_i.positive?

    #     puts "Are you sure you want to delete #{account.cards[reply.to_i - 1].number}?[y/n]"

    #     reply2 = gets.strip.downcase

    #     return if reply2 == 'n'

    #     account.cards.delete_at(reply.to_i - 1) if reply2 == 'y'
    #   end
    # end
  end
end
