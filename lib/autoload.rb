# frozen_string_literal: true

require 'i18n'
require 'yaml'
require 'pry'
require 'digest'

require_relative '../config/app_config'

require_relative 'helpers/db_helper'
require_relative 'helpers/validation_helper'

require_relative 'validators/card_validator'
require_relative 'validators/account_validator'
require_relative 'validators/transaction_validator'

require_relative 'banking_app/ui'

require_relative 'cards/base'
require_relative 'cards/usual_card'
require_relative 'cards/capitalist_card'
require_relative 'cards/virtual_card'

require_relative 'banking_app/account_builder'
require_relative 'banking_app/account'
require_relative 'banking_app/console'

require_relative '../initializers/i18n'

I18n.config.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
