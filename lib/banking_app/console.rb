# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Console
  prepend ConsoleAppConfig
  prepend UI
  prepend DBHelper

  def initialize
    @current_account          = nil
    @recipient_account        = nil
    @send_transaction_status  = nil
  end

  def run
    show_bank_menu

    case gets.strip.downcase
    when COMMANDS[:create] then create_account
    when COMMANDS[:load]   then load_account
    when COMMANDS[:exit]   then exit
    else abort(I18n.t('ACCOUNT.ERRORS.INVALID_OPTION'))
    end

    account_menu
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
  def account_menu
    loop do
      show_account_menu(@current_account)

      case gets.strip
      when COMMANDS[:show_cards]      then show_cards
      when COMMANDS[:create_card]     then create_card
      when COMMANDS[:destroy_card]    then destroy_card
      when COMMANDS[:put_money]       then put_money
      when COMMANDS[:withdraw_money]  then withdraw_money
      when COMMANDS[:send_money]      then send_money
      when COMMANDS[:destroy_account] then return destroy_account
      when COMMANDS[:exit]            then exit
      else warn_abount :wrong_command
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

  def create_account
    loop do
      account = AccountBuilder.build do |builder|
        builder.set_name(input(:name))
        builder.set_age(input(:age))
        builder.set_login_credentials(input(:login), input(:password))
        builder.set_empty_cards_list
      end

      next unless account

      break Account.add @current_account = account
    end
  end

  def load_account
    return create_the_first_account if accounts.none?

    attempts = 0

    loop do
      abort(I18n.t('ACCOUNT.ERRORS.LOGIN_ATTEMPTS')) if attempts >= AccountValidator::TRUSTED_LOGIN_ATTEMPTS_COUNT

      credentials = obtain_account_credentials
      attempts += 1

      next warn_abount :unknown_account unless AccountValidator.account_exists?(credentials)

      break setup_account(credentials[0])
    end
  end

  def destroy_account
    show('ACCOUNT.DESTROY_CONFIRMATION', with_invite: true)

    Account.destroy(@current_account) if confirmed?
  end

  def create_the_first_account
    show('ACCOUNT.FIRST_REQUEST', with_invite: true)

    confirmed? ? create_account : run
  end

  def show_cards
    return show('CARD.ERRORS.NO_CARDS_AVAILABLE') unless CardValidator.cards_available?(@current_account)

    show_active_cards(@current_account)
  end

  def create_card
    loop do
      show_cards_creation_menu

      card_type = gets.strip

      return if card_type == COMMANDS[:exit]

      next warn_abount(:wrong_card_type) unless CardValidator.card_type_valid?(card_type)

      break Account.add_card(account: @current_account, type: card_type.intern)
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

    Account.destroy_card(@current_account, choosen_card_index)

    Account.update(@current_account)
  end

  def withdraw_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(operation: :withdraw)

    return unless amount

    withdraw(@current_account, @current_account.cards[choosen_card_index], amount)
  end

  def put_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    amount = obtain_amount(operation: :put)

    return unless amount

    put(@current_account, @current_account.cards[choosen_card_index], amount)
  end

  def send_money
    choosen_card_index = convert_to_index choose_card

    return if choosen_card_index.negative?

    recipient_data = obtain_recipient_data

    return unless recipient_data

    amount = obtain_amount(operation: :send)

    return unless amount

    send(@current_account, @current_account.cards[choosen_card_index], recipient_data, amount)
  end

  private

  def withdraw(account, card, amount, send_context: false)
    tax = send_context ? card.send_tax(amount) : card.withdraw_tax(amount)

    return show('OPERATOR.ERRORS.NOT_ENOUGH_MONEY') unless TransactionValidator.amount_valid?(card, amount, tax)

    Cards::Base.update_balance(card, amount, tax, operation: :withdraw)

    Account.update account

    show('OPERATOR.WITHDRAW', amount: amount, card_number: card.number, card_balance: card.balance, tax: tax)
  end

  def put(account, card, amount)
    tax = card.put_tax(amount)

    return show('OPERATOR.ERRORS.HIGH_TAX') unless TransactionValidator.tax_valid?(amount, tax)

    Cards::Base.update_balance(card, amount, tax, operation: :put)

    Account.update account

    show('OPERATOR.PUT', amount: amount, card_number: card.number, card_balance: card.balance, tax: tax)
  end

  def send(sender_account, sender_card, recipient_data, amount)
    recipient_card = recipient_data[:account].cards.detect { |card| card.number == recipient_data[:card_number] }

    withdraw(sender_account, sender_card, amount, send_context: true)

    put(recipient_data[:account], recipient_card, amount)
  end

  def confirmed?
    gets.strip.downcase == COMMANDS[:yes]
  end

  def input(credential)
    show(:"ACCOUNT.#{credential.upcase}_REQUEST", with_invite: true)

    gets.strip
  end

  def obtain_account_credentials
    show('ACCOUNT.LOGIN_REQUEST', with_invite: true)
    login = gets.strip

    show('ACCOUNT.PASSWORD_REQUEST', with_invite: true)
    password = gets.strip

    [login, password]
  end

  def setup_account(login)
    @current_account = accounts.detect { |account| login == account.login }
  end

  def obtain_amount(operation:)
    show('OPERATOR.AMOUNT_REQUEST', operation: operation, with_invite: true)

    amount = gets.strip.to_f

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
# rubocop:enable Metrics/ClassLength
