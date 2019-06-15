# frozen_string_literal: true

module UI
  USER_INVITE = '[~]>> '

  def show(*messages, with_invite: false, **payload)
    puts I18n.t(*messages, **payload)

    print USER_INVITE if with_invite
  end

  def show_bank_menu
    show :WELCOME
    show('ACCOUNT.OPTIONS')
    show :EXIT_OPTION, with_invite: true
  end

  def show_active_cards(account)
    show('CARD.AVAILABLE')

    account.cards.each_with_index { |card, i| puts "#{card.number}, #{card.type}, # - #{i + 1}" }
  end

  def show_cards_creation_menu
    show('CARD.TYPES')
    show :EXIT_OPTION, with_invite: true
  end

  def show_card_choosing_menu(account)
    show('CARD.CHOOSE')

    show_active_cards(account)

    show :EXIT_OPTION, with_invite: true
  end

  def show_errors(errors)
    puts '[!]-----------------------------------------------------------------[!]'
    errors.values.each(&method(:puts))
    puts '[!]-----------------------------------------------------------------[!]'
  end

  def warn_abount(error_type)
    case error_type
    when :wrong_card_type then show('CARD.ERRORS.WRONG_TYPE')
    when :wrong_command   then show('WRONG_COMMAND')
    end
  end

  def show_account_menu(account)
    show('ACCOUNT.USER_WELCOME', name: account.name)
    show('ACCOUNT.MENU', with_invite: true)
  end
end
