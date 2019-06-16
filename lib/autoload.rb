# frozen_string_literal: true

require 'i18n'
require 'yaml'
require 'pry'
require 'digest'

require_relative '../config/app_config'

require_relative 'helpers/db_helper'
require_relative 'helpers/account_cli_helper'
require_relative 'helpers/card_cli_helper'
require_relative 'helpers/operator_cli_helper'

require_relative 'validators/card_validator'
require_relative 'validators/account_validator'
require_relative 'validators/transaction_validator'

require_relative 'banking_app/ui'
require_relative 'banking_app/card'
require_relative 'banking_app/operator'
require_relative 'banking_app/account_builder'
require_relative 'banking_app/account'
require_relative 'banking_app/console'

I18n.config.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
I18n.config.available_locales = :en
I18n.default_locale = :en
