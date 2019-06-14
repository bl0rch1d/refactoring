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
    errors[:name] << I18n.t('ACCOUNT.ERRORS.BAD_NAME') unless value.match?(/\A[A-Z]/)
  end

  def validate_uniqueness(value)
    errors[:login] << I18n.t('ACCOUNT.ERRORS.ACCOUNT_EXISTS') if accounts.map(&:login).include? value
  end

  def validate_login(value)
    errors[:login] << I18n.t('ACCOUNT.ERRORS.LOGIN.EMPTY') if value.empty?

    errors[:login] << I18n.t('ACCOUNT.ERRORS.LOGIN.SHORT') if value.length < 4

    errors[:login] << I18n.t('ACCOUNT.ERRORS.LOGIN.LONG') if value.length > 20
  end

  def validate_password(value)
    errors[:password] << I18n.t('ACCOUNT.ERRORS.PASSWORD.EMPTY') if value.empty?

    errors[:password] << I18n.t('ACCOUNT.ERRORS.PASSWORD.SHORT') if value.length < 6

    errors[:password] << I18n.t('ACCOUNT.ERRORS.PASSWORD.LONG') if value.length > 30
  end

  def validate_age(value)
    value = value.to_i

    errors[:age] << I18n.t('ACCOUNT.ERRORS.AGE.NOT_A_NUMBER') unless value.is_a? Integer

    errors[:age] << I18n.t('ACCOUNT.ERRORS.AGE.SMALL') unless value >= 23

    errors[:age] << I18n.t('ACCOUNT.ERRORS.AGE.BIG') unless value <= 90
  end
end
# rubocop:enable Naming/AccessorMethodName
