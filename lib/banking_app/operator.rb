# frozen_string_literal: true

class Operator
  prepend UI

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

  def withdraw(card, amount)
    tax = calculate_tax(card_type: card.type, operation: :withdraw, amount: amount)

    return show('OPERATOR.ERRORS.NOT_ENOUGH_MONEY') unless TransactionValidator.amount_valid?(card, amount, tax)

    perform_transaction(
      operation: :withdraw,
      card: card,
      amount: amount,
      tax: tax
    )
  end

  def put(card, amount)
    tax = calculate_tax(card_type: card.type, operation: :put, amount: amount)

    return show('OPERATOR.ERRORS.HIGH_TAX') unless TransactionValidator.tax_valid?(amount, tax)

    perform_transaction(
      operation: :put,
      card: card,
      amount: amount,
      tax: tax
    )
  end

  private

  def calculate_tax(card_type:, operation:, amount:)
    return TAXES[card_type.intern][operation] if operation == :put && TAXES.keys[1..-1].include?(card_type.intern)

    TAXES[card_type.intern][operation] * amount
  end

  def perform_transaction(operation:, card:, amount:, tax:)
    operation == :put ? card.balance += (amount - tax) : card.balance -= (amount - tax)

    Account.update @account

    show(
      "OPERATOR.#{operation.upcase}",
      amount: amount,
      card_number: card.number,
      card_balance: card.balance,
      tax: tax
    )
  end
end
