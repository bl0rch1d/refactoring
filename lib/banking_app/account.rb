# frozen_string_literal: true

class Account
  extend DBHelper

  attr_accessor :name, :age, :login, :password, :cards

  class << self
    def add(new_account)
      save accounts << new_account
    end

    def update(account_to_update)
      save accounts.map { |account| account.login == account_to_update.login ? account_to_update : account }.compact
    end

    def destroy(account_to_delete)
      save accounts.map { |account| account if account.login != account_to_delete.login }.compact
    end
  end
end
