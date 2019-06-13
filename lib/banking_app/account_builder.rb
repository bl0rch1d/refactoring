# frozen_string_literal: true

require_relative 'account'
require_relative '../helpers/db'
require_relative 'ui'

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
    validate_name(name)

    return unless errors[:name].empty?

    account.name = name
  end

  def set_age(age)
    validate_age(age)

    return unless errors[:age].empty?

    account.age = age
  end

  def set_login_credentials(login, password)
    validate_login(login)
    validate_uniqueness(login)
    validate_password(password)

    return unless errors[:login].empty? || errors[:password].empty?

    account.login = login
    account.password = Digest::SHA512.hexdigest password
  end

  def set_empty_cards_list
    account.cards = []
  end

  private

  def validate_name(value)
    errors[:name] << '[!] Your name must not be empty and starts with first upcase letter' unless value.match?(/\A[A-Z]/)
  end

  def validate_uniqueness(value)
    errors[:login] << '[!] Such account is already exists' if accounts.map(&:login).include? value
  end

  def validate_login(value)
    errors[:login] << '[!] Login must present' if value.empty?

    errors[:login] << '[!] Login must be longer then 4 symbols' if value.length < 4

    errors[:login] << '[!] Login must be shorter then 20 symbols' if value.length > 20
  end

  def validate_password(value)
    errors[:password] << '[!] Password must present' if value.empty?

    errors[:password] << '[!] Password must be longer then 6 symbols' if value.length < 6

    errors[:password] << '[!] Password must be shorter then 30 symbols' if value.length > 30
  end

  def validate_age(value)
    value = value.to_i

    errors[:age] << '[!] Age must be a number' unless value.is_a? Integer

    errors[:age] << '[!] Your Age must be greater then 23' unless value >= 23

    errors[:age] << '[!] Your Age must be lower then 90' unless value <= 90
  end
end
# rubocop:enable Naming/AccessorMethodName
