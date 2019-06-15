# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName
class AccountBuilder
  include DBHelper

  def self.build
    extend UI

    builder = new
    yield builder

    return show_errors(builder.errors) unless builder.errors.values.all?(&:empty?)

    builder.account
  end

  attr_reader :account, :errors

  def initialize
    @account = Account.new

    @errors = {
      name: [],
      age: [],
      login: [],
      password: []
    }
  end

  def set_name(name)
    AccountValidator.check_name(name, errors)

    return unless errors[:name].empty?

    account.name = name
  end

  def set_age(age)
    AccountValidator.check_age(age, errors)

    return unless errors[:age].empty?

    account.age = age
  end

  def set_login_credentials(login, password)
    set_login(login)
    set_password(password)
  end

  def set_empty_cards_list
    account.cards = []
  end

  private

  def set_login(login)
    AccountValidator.check_login(login, errors)
    AccountValidator.check_uniqueness(accounts, login, errors)

    return unless errors[:login].empty?

    account.login = login
  end

  def set_password(password)
    AccountValidator.check_password(password, errors)

    return unless errors[:password].empty?

    account.password = obtain_hashsum password
  end
end
# rubocop:enable Naming/AccessorMethodName
