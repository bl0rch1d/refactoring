# frozen_string_literal: true

class Console
  include ConsoleAppConfig
  include UI
  include DBHelper
  include AccountCLIHelper
  include CardCLIHelper

  def initialize
    @current_account = nil
  end

  def run
    show_bank_menu

    case gets.strip.downcase
    when COMMANDS[:create] then create_account
    when COMMANDS[:load]   then load_account
    when COMMANDS[:exit]   then exit
    else return show('ACCOUNT.ERRORS.INVALID_OPTION')
    end

    account_menu
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def account_menu
    loop do
      show_main_menu_for(@current_account)

      case gets.strip
      when COMMANDS[:show_cards] then Card.show(@current_account)
      when COMMANDS[:create_card] then create_card
      when COMMANDS[:destroy_card] then destroy_card
      # when COMMANDS[:put_money] then put_money
      # when COMMANDS[:withdraw_money] then withdraw_money
      when COMMANDS[:destroy_account] then return destroy_account
      when COMMANDS[:exit] then exit
      else warn_abount :wrong_command
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def confirmed?
    gets.strip.downcase == COMMANDS[:yes]
  end

  def input(credential)
    show :"ACCOUNT.#{credential.upcase}_REQUEST"

    gets.strip
  end
end
