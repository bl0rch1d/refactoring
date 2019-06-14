# frozen_string_literal: true

module DBHelper
  include ConsoleAppConfig

  def save_account(account)
    save accounts << account
  end

  def load_account; end

  def update_data; end

  def wipe_data(path: OVERRIDABLE_FILENAME)
    File.delete(path)
  end

  private

  def save(data, path: ACCOUNTS_PATH)
    File.write(path, YAML.dump(data))
  end

  def accounts
    return [] unless File.exist?(ACCOUNTS_PATH)

    yaml = File.read(ACCOUNTS_PATH)
    Psych.safe_load(yaml, [Symbol, Account, Card])
  end
end
