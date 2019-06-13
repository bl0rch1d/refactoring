# frozen_string_literal: true

require 'yaml'
require 'pry'
require 'digest'

require_relative 'ui'
require_relative 'account'
require_relative 'card'
require_relative 'account_builder'
require_relative '../helpers/db'
require_relative '../../config/config'

class Console
  include UI
  include DBHelper

  COMMANDS = {
    create: 'create',
    load: 'load',
    exit: 'exit'
  }.freeze

  def initialize
    @current_account = nil
  end

  def run
    show_accounts_menu

    case gets.strip.downcase
    when COMMANDS[:create] then create_account
    when COMMANDS[:load]   then load_account
    when COMMANDS[:exit]   then exit
    else return show('ERRORS.INVALID_OPTION')
    end

    main_menu
  end

  def create_account
    loop do
      @current_account = AccountBuilder.build do |builder|
        builder.set_name(input(:name))
        builder.set_age(input(:age))
        builder.set_login_credentials(input(:login), input(:password))
        builder.set_empty_cards_list
      end

      break unless @current_account.nil?
    end

    save_account @current_account
  end

  def input(credential)
    show :"#{credential.upcase}_REQUEST"

    gets.strip
  end

  def load_account
    loop do
      return create_the_first_account if accounts.none?

      show :LOGIN_REQUEST
      login = gets.strip

      show :PASSWORD_REQUEST
      password = gets.strip

      break setup_account(login) if account_exists?(login, password)
    end
  end

  def setup_account(login)
    @current_account = accounts.detect { |account| login == account.login }
  end

  def account_exists?(login, password)
    return true if accounts.map do |account|
      { login: account.login, password: account.password }
    end.include?(login: login, password: Digest::SHA512.hexdigest(password))

    show :NO_ACCOUNT_ERROR
  end

  def create_the_first_account
    show :FIRST_ACCOUNT_REQUEST, with_invite: true

    reply = gets.strip.downcase

    return create_account if reply == 'y'

    run
  end

  def main_menu
    loop do
      show_main_menu_for(@current_account)

      case gets.strip
      when 'SC' then Card.show_cards_for(@current_account)
      when 'CC' then create_card
      # when 'DC' then destroy_card
      # when 'PM' then put_money
      # when 'WM' then withdraw_money
      when 'DA'   then return destroy_account
      when 'exit' then exit
      else warn_abount :wrong_command
      end
    end
  end

  def create_card
    loop do
      show_cards_creation_menu

      type = gets.strip

      return if type == 'exit'

      break Card.add(account: @current_account, type: type.intern) if Card::TEMPLATES.include? type.intern

      warn_abount :wrong_card_type
    end

    Account.update(@current_account)
  end

  def destroy_account
    puts 'Are you sure you want to destroy account?[y/n]'

    Account.destroy(@current_account) if gets.strip == 'y'
  end
end
