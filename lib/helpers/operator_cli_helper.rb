# frozen_string_literal: true

module OperatorCLIHelper
  def withdraw_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(:withdraw)

    return if amount.nil?

    @operator.withdraw(@current_account.cards[choosen_card_index], amount)
  end

  def put_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(:put)

    return if amount.nil?

    @operator.put(@current_account.cards[choosen_card_index], amount)
  end

  private

  def obtain_amount(operation)
    show('OPERATOR.AMOUNT_REQUEST', operation: operation)

    amount = gets.strip.to_i

    return show('OPERATOR.ERRORS.INCORRECT_AMOUNT') if amount <= 0

    amount
  end
end
