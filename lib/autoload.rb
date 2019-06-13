# frozen_string_literal: true

require 'i18n'

require_relative 'banking_app/account'
require_relative 'banking_app/card'
require_relative 'banking_app/console'

I18n.config.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
I18n.config.available_locales = :en
I18n.default_locale = :en
