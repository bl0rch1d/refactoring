# frozen_string_literal: true

module UI
  USER_INVITE = "\n[~]>> "

  def show(*messages, with_invite: false, **payload)
    puts I18n.t(*messages, **payload)

    print USER_INVITE if with_invite
  end

  def show_accounts_menu
    show :WELCOME
    show :ACCOUNT_OPTIONS
    show :EXIT_OPTION, with_invite: true
  end

  def show_card_removing_menu(cards)
    show :IF_YOU_WANT_TO_DELETE

    cards.each_with_index { |card, i| puts "- #{card.number}, #{card.type}, press #{i + 1}" }

    show :EXIT_OPTION, with_invite: true
  end

  def show_cards_creation_menu
    show :CARD_TYPES
    show :EXIT_OPTION, with_invite: true
  end

  def show_errors(errors)
    puts '[!]-----------------------------------------------------------------[!]'
    errors.values.each(&method(:puts))
    puts '[!]-----------------------------------------------------------------[!]'
  end

  def warn_abount(error_type)
    case error_type
    when :wrong_card_type then puts "Wrong card type. Try again!\n"
    when :wrong_command   then puts "Wrong command. Try again!\n"
    end
  end

  def show_main_menu_for(account)
    show :USER_WELCOME, name: account.name
    show :MAIN_MENU, with_invite: true
  end
end
