# frozen_string_literal: true

module OperatorCLIHelper
  def withdraw_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(operation: :withdraw)

    return unless amount

    @operator.withdraw(@current_account.cards[choosen_card_index], amount)
  end

  def put_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(operation: :put)

    return unless amount

    @operator.put(@current_account.cards[choosen_card_index], amount)
  end

  def send_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    recipient_data = obtain_recipient_data

    return unless recipient_data

    amount = obtain_amount(operation: :send)

    return unless amount

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

    recipient_account = accounts.detect { |account| account.cards.map(&:number).include? card_number }

    return show('CARD.ERRORS.NO_SUCH_CARD', card_number: card_number) unless recipient_account

    {
      account: recipient_account,
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
