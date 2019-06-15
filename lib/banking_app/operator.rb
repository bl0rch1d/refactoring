# frozen_string_literal: true

class Operator
  TAXES = {
    usual: {
      withdraw: 0.05,
      put: 0.02
    },

    capitalist: {
      withdraw: 0.04,
      put: 10
    },

    virtual: {
      withdraw: 0.88,
      put: 1
    }
  }.freeze

  private_constant :TAXES

  def initialize(account)
    @account = account
  end

  def withdraw_money(card, amount)
    tax = calculate_tax(card_type: card.type, operation: :withdraw, amount: amount)

    return unless amount_valid?(card, amount, tax)

    card.balance -= (amount - tax)

    Account.update @account

    puts "\n#{amount}$ withdrawed from #{card.number}."
    puts "Money left: #{card.balance}$. Tax: #{tax}$"
  end

  def put_money(card, amount)
    tax = calculate_tax(card_type: card.type, operation: :put, amount: amount)

    return unless high_tax?(amount, tax)

    card.balance += (amount - tax)

    Account.update @account

    puts "\n#{amount}$ was put on #{card.number}. Balance: #{card.balance}$. Tax: #{tax}$"
  end

  private

  def calculate_tax(card_type:, operation:, amount:)
    return TAXES[card_type.intern][operation] if operation == :put && TAXES.keys[1..-1].include?(card_type.intern)

    TAXES[card_type.intern][operation] * amount
  end

  def amount_valid?(card, amount, tax)
    return puts "You don't have enough money on card for such operation" if (card.balance - amount - tax).negative?

    true
  end

  def high_tax?(amount, tax)
    return puts 'Your tax is higher than input amount' if tax > amount

    true
  end
end
