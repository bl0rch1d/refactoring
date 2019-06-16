# frozen_string_literal: true

module CardCLIHelper
  include ConsoleAppConfig

  def show_cards
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    show_active_cards(@current_account)
  end

  def create_card
    loop do
      show_cards_creation_menu

      card_type = gets.strip

      return if card_type == COMMANDS[:exit]

      break Card.add(account: @current_account, type: card_type.intern) if Card::TEMPLATES.include? card_type.intern

      warn_abount :wrong_card_type
    end

    Account.update(@current_account)
  end

  def destroy_card
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    choosen_card = convert_to_index choose_card

    return if choosen_card.negative?

    show('CARD.REMOVING_CONFIRMATION',
         card_number: @current_account.cards[choosen_card].number,
         with_invite: true)

    return unless confirmed?

    Card.destroy(@current_account, choosen_card)

    Account.update(@current_account)
  end

  private

  def convert_to_index(choosen_card)
    choosen_card.to_i - 1
  end

  def choose_card
    show_card_choosing_menu(@current_account)

    card = gets.strip

    return if card == COMMANDS[:exit]

    unless CardValidator.valid_card_index?(@current_account.cards.size, card.to_i)
      return show('CARD.ERRORS.WRONG_INDEX')
    end

    card
  end
end
