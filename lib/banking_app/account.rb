# frozen_string_literal: true

class Account
  prepend ConsoleAppConfig
  prepend UI
  extend DBHelper

  attr_accessor :name, :age, :login, :password, :cards

  class << self
    def add(account)
      save accounts << account
    end

    def update(account_to_update)
      save accounts.map { |account| account.login == account_to_update.login ? account_to_update : account }.compact
    end

    def destroy(account_to_delete)
      save accounts.map { |account| account if account.login != account_to_delete.login }.compact
    end
  end
end
