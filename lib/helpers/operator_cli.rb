# frozen_string_literal: true

module OperatorCLIHelper
  def withdraw_money
    loop do
      return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

      choosen_card = convert_to_index choose_card

      return if choosen_card.negative?

      amount = obtain_amount(:withdraw)

      return if amount.nil?

      return @operator.withdraw_money(@current_account.cards[choosen_card], amount)
    end
  end

  def put_money
    loop do
      return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

      choosen_card = convert_to_index choose_card

      return if choosen_card.negative?

      amount = obtain_amount(:put)

      return if amount.nil?

      return @operator.put_money(@current_account.cards[choosen_card], amount)
    end
  end

  private

  def obtain_amount(operation)
    puts "Input the amount of money you want to #{operation}"

    amount = gets.strip.to_i

    return puts 'You must input correct amount of $' if amount.negative?

    amount
  end
end
