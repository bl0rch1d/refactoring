# frozen_string_literal: true

class Console
  include ConsoleAppConfig
  prepend UI
  prepend DBHelper
  prepend AccountCLIHelper
  prepend CardCLIHelper
  prepend OperatorCLIHelper

  def initialize
    @current_account  = nil
    @operator         = nil
  end

  def run
    show_bank_menu

    case gets.strip.downcase
    when COMMANDS[:create] then create_account
    when COMMANDS[:load]   then load_account
    when COMMANDS[:exit]   then exit
    else return show('ACCOUNT.ERRORS.INVALID_OPTION')
    end

    set_operator
    account_menu
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
  def account_menu
    loop do
      show_account_menu(@current_account)

      case gets.strip
      when COMMANDS[:show_cards] then show_cards
      when COMMANDS[:create_card] then create_card
      when COMMANDS[:destroy_card] then destroy_card
      when COMMANDS[:put_money] then put_money
      when COMMANDS[:withdraw_money] then withdraw_money
      when COMMANDS[:destroy_account] then return destroy_account
      when COMMANDS[:exit] then exit
      else warn_abount :wrong_command
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

  private

  def set_operator
    @operator = Operator.new(@current_account)
  end

  def confirmed?
    gets.strip.downcase == COMMANDS[:yes]
  end

  def input(credential)
    show :"ACCOUNT.#{credential.upcase}_REQUEST"

    gets.strip
  end
end
