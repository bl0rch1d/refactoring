# frozen_string_literal: true

module CardCLIHelper
  include ConsoleAppConfig

  def create_card
    loop do
      show_cards_creation_menu

      type = gets.strip

      return if type == COMMANDS[:exit]

      break Card.add(account: @current_account, type: type.intern) if Card::TEMPLATES.include? type.intern

      warn_abount :wrong_card_type
    end

    Account.update(@current_account)
  end

  def destroy_card
    loop do
      break show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless Card::Validator.cards_available?(@current_account)

      show_card_removing_menu(@current_account.cards)

      card_index = gets.strip

      return if card_index == COMMANDS[:exit]

      return show('CARD.ERRORS.WRONG_INDEX') unless Card::Validator.valid_card_index?(@current_account.cards.size, card_index.to_i)

      show('CARD.REMOVING_CONFIRMATION',
           card_number: @current_account.cards[card_index.to_i - 1].number,
           with_invite: true)

      Card.destroy(@current_account, card_index.to_i - 1) if confirmed?

      Account.update(@current_account)
    end
  end
end
