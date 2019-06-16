# frozen_string_literal: true

module CardCLIHelper
  prepend ConsoleAppConfig

  def show_cards
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    show_active_cards(@current_account)
  end

  def create_card
    loop do
      show_cards_creation_menu

      card_type = gets.strip

      return if card_type == COMMANDS[:exit]

      next warn_abount(:wrong_card_type) unless Card::TEMPLATES.include? card_type.intern

      break Card.add(account: @current_account, type: card_type.intern)
    end

    Account.update(@current_account)
  end

  def destroy_card
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    show(
      'CARD.REMOVING_CONFIRMATION',
      card_number: @current_account.cards[choosen_card_index].number,
      with_invite: true
    )

    return unless confirmed?

    Card.destroy(@current_account, choosen_card_index)

    Account.update(@current_account)
  end

  private

  def convert_to_index(choosen_card)
    choosen_card.to_i - 1
  end

  def choose_card
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    show_card_choosing_menu(@current_account)

    card_index = gets.strip

    return if card_index == COMMANDS[:exit]

    unless CardValidator.valid_card_index?(@current_account.cards.size, card_index.to_i)
      return show('CARD.ERRORS.WRONG_INDEX')
    end

    card_index
  end
end
