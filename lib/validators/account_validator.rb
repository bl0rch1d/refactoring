# frozen_string_literal: true

class AccountValidator
  TRUSTED_LOGIN_ATTEMPTS_COUNT = 3

  class << self
    include DBHelper

    def check_name(value, errors)
      errors[:name] << I18n.t('ACCOUNT.ERRORS.BAD_NAME') unless value.match?(/\A[A-Z]/)
    end

    def check_uniqueness(value, errors)
      errors[:login] << I18n.t('ACCOUNT.ERRORS.ACCOUNT_EXISTS') if accounts.map(&:login).include? value
    end

    def check_login(value, errors)
      errors[:login] << I18n.t('ACCOUNT.ERRORS.LOGIN.EMPTY') if value.empty?

      errors[:login] << I18n.t('ACCOUNT.ERRORS.LOGIN.SHORT') if value.length < 4

      errors[:login] << I18n.t('ACCOUNT.ERRORS.LOGIN.LONG') if value.length > 20
    end

    def check_password(value, errors)
      errors[:password] << I18n.t('ACCOUNT.ERRORS.PASSWORD.EMPTY') if value.empty?

      errors[:password] << I18n.t('ACCOUNT.ERRORS.PASSWORD.SHORT') if value.length < 6

      errors[:password] << I18n.t('ACCOUNT.ERRORS.PASSWORD.LONG') if value.length > 30
    end

    def check_age(value, errors)
      value = value.to_i

      errors[:age] << I18n.t('ACCOUNT.ERRORS.AGE.NOT_A_NUMBER') unless value.is_a? Integer

      errors[:age] << I18n.t('ACCOUNT.ERRORS.AGE.SMALL') unless value >= 23

      errors[:age] << I18n.t('ACCOUNT.ERRORS.AGE.BIG') unless value <= 90
    end

    def account_exists?(credentials)
      login, password = credentials

      accounts.detect do |account|
        return true if account.login == login && account.password == obtain_hashsum(password)
      end
    end
  end
end
