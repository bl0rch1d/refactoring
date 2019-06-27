# frozen_string_literal: true

module ConsoleAppConfig
  ACCOUNTS_PATH = 'db/accounts.yml'

  LOGIN_LENGTH_RANGE    = (4..20).to_a.freeze
  PASSWORD_LENGTH_RANGE = (6..30).to_a.freeze
  AGE_RANGE             = (23..90).to_a.freeze

  COMMANDS = {
    create: 'create',
    load: 'load',
    exit: 'exit',
    yes: 'y',
    show_cards: 'SC',
    create_card: 'CC',
    destroy_card: 'DC',
    put_money: 'PM',
    withdraw_money: 'WM',
    send_money: 'SM',
    destroy_account: 'DA'
  }.freeze
end
