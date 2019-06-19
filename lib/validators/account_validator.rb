# frozen_string_literal: true

class AccountValidator
  TRUSTED_LOGIN_ATTEMPTS_COUNT = 3

  class << self
    include ValidationHelper
    include DBHelper

    def check_name(value)
      [validate_capitalized_string(value: value, field: :name)].compact
    end

    def check_login(value)
      [
        validate_length_range(value: value, field: :login, range: LOGIN_LENGTH_RANGE),
        validate_emptyness(value: value, field: :login),
        validate_account_uniqueness(value)
      ].compact
    end

    def check_password(value)
      [
        validate_length_range(value: value, field: :password, range: PASSWORD_LENGTH_RANGE),
        validate_emptyness(value: value, field: :password)
      ].compact
    end

    def check_age(value)
      value = value.to_i

      [
        validate_integer(value: value, field: :age),
        validate_integer_range(value: value, field: :age, range: AGE_RANGE)
      ].compact
    end

    def account_exists?(credentials)
      login, password = credentials

      accounts.detect do |account|
        return true if account.login == login && account.password == obtain_hashsum(password)
      end
    end
  end
end
