# frozen_string_literal: true

class Operator
  prepend UI

  def initialize(account)
    @account                  = account
    @recipient_account        = nil
    @send_transaction_status  = nil
  end

  def withdraw(card, amount, send_context: false)
    tax = calculate_tax(card: card, operation: (send_context ? :send : :withdraw), amount: amount)

    return show('OPERATOR.ERRORS.NOT_ENOUGH_MONEY') unless TransactionValidator.amount_valid?(card, amount, tax)

    perform_transaction(
      operation: :withdraw,
      card: card,
      amount: amount,
      tax: tax
    )

    @send_transaction_status = :pending if send_context
  end

  def put(card, amount)
    tax = calculate_tax(card: card, operation: :put, amount: amount)

    return show('OPERATOR.ERRORS.HIGH_TAX') unless TransactionValidator.tax_valid?(amount, tax)

    perform_transaction(
      operation: :put,
      card: card,
      amount: amount,
      tax: tax
    )
  end

  def send(sender_card, recipient_data, amount)
    recipient_card = recipient_data[:account].cards.detect { |card| card.number == recipient_data[:card_number] }

    withdraw(sender_card, amount, send_context: true)

    return if @send_transaction_status != :pending

    @recipient_account = recipient_data[:account]

    put(recipient_card, amount)

    @recipient_account = nil
  end

  private

  def calculate_tax(card:, operation:, amount:)
    case operation
    when :withdraw then card.withdraw_tax(amount)
    when :put      then card.put_tax(amount)
    when :send     then card.send_tax(amount)
    end
  end

  def perform_transaction(operation:, card:, amount:, tax:)
    operation == :put ? card.balance += (amount - tax) : card.balance -= (amount + tax)

    Account.update @recipient_account || @account

    show(
      "OPERATOR.#{operation.upcase}",
      amount: amount,
      card_number: card.number,
      card_balance: card.balance,
      tax: tax
    )
  end
end
