# frozen_string_literal: true

module AccountCLIHelper
  include ConsoleAppConfig

  def create_account
    loop do
      @current_account = AccountBuilder.build do |builder|
        builder.set_name(input(:name))
        builder.set_age(input(:age))
        builder.set_login_credentials(input(:login), input(:password))
        builder.set_empty_cards_list
      end

      break unless @current_account.nil?
    end

    save_account @current_account
  end

  def load_account
    loop do
      return create_the_first_account if accounts.none?

      credentials = obtain_account_credentials

      break setup_account(credentials[0]) if account_exists?(credentials)
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

  def obtain_account_credentials
    show('ACCOUNT.LOGIN_REQUEST')
    login = gets.strip

    show('ACCOUNT.PASSWORD_REQUEST')
    password = gets.strip

    [login, password]
  end

  def setup_account(login)
    @current_account = accounts.detect { |account| login == account.login }
  end

  def account_exists?(credentials)
    login, password = credentials

    return true if accounts.map do |account|
      { login: account.login, password: account.password }
    end.include?(login: login, password: Digest::SHA512.hexdigest(password))

    show('ACCOUNT.ERRORS.NO_ACCOUNT')
  end
end
