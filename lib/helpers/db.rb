# frozen_string_literal: true

require_relative '../../config/config'

module DBHelper
  def save_account(account, path: ACCOUNTS_PATH)
    new_accounts = accounts << account

    File.open(path, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def load_account; end

  def update_data; end

  private

  def accounts
    return [] unless File.exist?(ACCOUNTS_PATH)

    YAML.load_file(ACCOUNTS_PATH)
  end
end
