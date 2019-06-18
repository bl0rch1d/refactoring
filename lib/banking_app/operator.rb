# frozen_string_literal: true

class Operator
  prepend UI

  def initialize(account)
    @account             = account
    @recipient_account   = nil
    @transaction_success = false
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

    return unless @transaction_success

    @recipient_account = recipient_data[:account]

    put(recipient_card, amount)

    @recipient_account = nil
  end

  private

  def calculate_tax(card:, operation:, amount:)
    tax_factor = card.taxes[operation]
    card_type = card.class.to_s.split('::')[1]

    case operation
    when :withdraw then tax_factor * amount
    when :put      then card_type == 'Usual' ? tax_factor * amount : tax_factor
    when :send     then card_type == 'Capitalist' ? tax_factor * amount : tax_factor
    end
  end

  def perform_transaction(operation:, card:, amount:, tax:)
    operation == :put ? card.balance += (amount - tax) : card.balance -= (amount + tax)

    Account.update @recipient_account || @account

    @transaction_success = true

    show(
      "OPERATOR.#{operation.upcase}",
      amount: amount,
      card_number: card.number,
      card_balance: card.balance,
      tax: tax
    )
  end
end
