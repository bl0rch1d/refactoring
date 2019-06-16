# frozen_string_literal: true

module ConsoleAppConfig
  ACCOUNTS_PATH = 'db/accounts.yml'

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
    destroy_account: 'DA'
  }.freeze
end
