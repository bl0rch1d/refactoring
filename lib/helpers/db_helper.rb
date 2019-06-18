# frozen_string_literal: true

module DBHelper
  prepend ConsoleAppConfig

  private

  def obtain_hashsum(data)
    Digest::SHA512.hexdigest data
  end

  def save(data, path: ACCOUNTS_PATH)
    File.write(path, YAML.dump(data))
  end

  def accounts
    return [] unless File.exist?(ACCOUNTS_PATH)

    yaml = File.read(ACCOUNTS_PATH)
    Psych.safe_load(yaml, [Symbol, Account, Cards::Usual, Cards::Capitalist, Cards::Virtual])
  end
end
