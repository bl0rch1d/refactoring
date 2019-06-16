# frozen_string_literal: true

module OperatorCLIHelper
  def withdraw_money
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    choosen_card = convert_to_index choose_card

    return if choosen_card.negative?

    amount = obtain_amount(:withdraw)

    return if amount.nil?

    @operator.withdraw_money(@current_account.cards[choosen_card], amount)
  end

  def put_money
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    choosen_card = convert_to_index choose_card

    return if choosen_card.negative?

    amount = obtain_amount(:put)

    return if amount.nil?

    @operator.put_money(@current_account.cards[choosen_card], amount)
  end

  private

  def obtain_amount(operation)
    show('OPERATOR.AMOUNT_REQUEST', operation: operation)

    amount = gets.strip.to_i

    return show('OPERATOR.ERRORS.INCORRECT_AMOUNT') if amount <= 0

    amount
  end
end
