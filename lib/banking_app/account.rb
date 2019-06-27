# frozen_string_literal: true

class Account
  extend DBHelper

  attr_accessor :name, :age, :login, :password, :cards

  class << self
    def add(new_account)
      save accounts << new_account
    end

    def update(account_to_update)
      save(accounts.map { |account| account.login == account_to_update.login ? account_to_update : account })
    end

    def destroy(account_to_delete)
      save(accounts.reject { |account| account.login == account_to_delete.login })
    end

    def add_card(account:, type:)
      account.cards <<= Cards.const_get(type.capitalize).new
    end

    def destroy_card(account, card_index)
      account.cards.delete_at(card_index)
    end
  end
end
