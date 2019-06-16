# frozen_string_literal: true

module AccountCLIHelper
  prepend ConsoleAppConfig

  def create_account
    loop do
      account = AccountBuilder.build do |builder|
        builder.set_name(input(:name))
        builder.set_age(input(:age))
        builder.set_login_credentials(input(:login), input(:password))
        builder.set_empty_cards_list
      end

      next if account.nil?

      break Account.add @current_account = account
    end
  end

  def load_account
    return create_the_first_account if accounts.none?

    loop do
      credentials = obtain_account_credentials

      next show('ACCOUNT.ERRORS.NO_ACCOUNT') unless AccountValidator.account_exists?(credentials)

      break setup_account(credentials[0])
    end
  end

  def destroy_account
    show('ACCOUNT.DESTROY_CONFIRMATION', with_invite: true)

    Account.destroy(@current_account) if confirmed?
  end

  def create_the_first_account
    show('ACCOUNT.FIRST_REQUEST', with_invite: true)

    return create_account if confirmed?

    run
  end

  private

  def input(credential)
    show(:"ACCOUNT.#{credential.upcase}_REQUEST", with_invite: true)

    gets.strip
  end

  def obtain_account_credentials
    show('ACCOUNT.LOGIN_REQUEST', with_invite: true)
    login = gets.strip

    show('ACCOUNT.PASSWORD_REQUEST', with_invite: true)
    password = gets.strip

    [login, password]
  end

  def setup_account(login)
    @current_account = accounts.detect { |account| login == account.login }
  end
end
