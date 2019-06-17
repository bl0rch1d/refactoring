# frozen_string_literal: true

module OperatorCLIHelper
  def withdraw_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(operation: :withdraw)

    return if amount.nil?

    @operator.withdraw(@current_account.cards[choosen_card_index], amount)
  end

  def put_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(operation: :put)

    return if amount.nil?

    @operator.put(@current_account.cards[choosen_card_index], amount)
  end

  def send_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    recipient_data = obtain_recipient_data

    return if recipient_data.nil?

    amount = obtain_amount(operation: :send)

    return if amount.nil?

    @operator.send(@current_account.cards[choosen_card_index], recipient_data, amount)
  end

  private

  def obtain_amount(operation:)
    show('OPERATOR.AMOUNT_REQUEST', operation: operation, with_invite: true)

    amount = gets.strip.to_i

    return show('OPERATOR.ERRORS.INCORRECT_AMOUNT') if amount <= 0

    amount
  end

  def obtain_recipient_data
    card_number = obtain_recipient_card_number

    account = accounts.detect { |x| x.cards.map(&:number).include? card_number }

    return show('CARD.ERRORS.NO_SUCH_CARD', card_number: card_number) if account.nil?

    {
      account: account,
      card_number: card_number
    }
  end

  def obtain_recipient_card_number
    show('OPERATOR.RECIPIENT_CARD_NUMBER_REQUEST', with_invite: true)

    card_number = gets.strip

    return show('CARD.ERRORS.CARD_NUMBER') unless CardValidator.card_number_valid?(card_number)

    card_number
  end
end
