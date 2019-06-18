# frozen_string_literal: true

RSpec.describe Account do
  OVERRIDABLE_FILENAME = 'spec/fixtures/accounts.yml'

  ASK_PHRASES = {
    name: I18n.t('ACCOUNT.NAME_REQUEST'),
    age: I18n.t('ACCOUNT.AGE_REQUEST'),
    login: I18n.t('ACCOUNT.LOGIN_REQUEST'),
    password: I18n.t('ACCOUNT.PASSWORD_REQUEST')
  }.freeze

  ACCOUNT_VALIDATION_PHRASES = {
    name: {
      first_letter: I18n.t('ACCOUNT.ERRORS.BAD_NAME')
    },
    login: {
      present: I18n.t('ACCOUNT.ERRORS.LOGIN.EMPTY'),
      longer: I18n.t('ACCOUNT.ERRORS.LOGIN.SHORT'),
      shorter: I18n.t('ACCOUNT.ERRORS.LOGIN.LONG'),
      exists: I18n.t('ACCOUNT.ERRORS.ACCOUNT_EXISTS')
    },
    password: {
      present: I18n.t('ACCOUNT.ERRORS.PASSWORD.EMPTY'),
      longer: I18n.t('ACCOUNT.ERRORS.PASSWORD.SHORT'),
      shorter: I18n.t('ACCOUNT.ERRORS.PASSWORD.LONG')
    },
    age: {
      greater: I18n.t('ACCOUNT.ERRORS.AGE.SMALL'),
      number: I18n.t('ACCOUNT.ERRORS.AGE.NOT_A_NUMBER'),
      lower: I18n.t('ACCOUNT.ERRORS.AGE.BIG')
    }
  }.freeze

  ERROR_PHRASES = {
    user_not_exists: I18n.t('ACCOUNT.ERRORS.NO_ACCOUNT'),
    wrong_command: I18n.t('WRONG_COMMAND'),
    no_active_cards: I18n.t('CARD.ERRORS.NO_CARDS_AVAILABLE'),
    wrong_card_type: I18n.t('CARD.ERRORS.WRONG_TYPE'),
    wrong_number: I18n.t('CARD.ERRORS.WRONG_INDEX'),
    correct_amount: I18n.t('OPERATOR.ERRORS.NOT_ENOUGH_MONEY'),
    tax_higher: I18n.t('OPERATOR.ERRORS.HIGH_TAX')
  }.freeze

  CARD_TYPES = Cards.constants.reject { |card_type| card_type == :Base }.map { |card_type| card_type.to_s.downcase }

  CARDS = [
    Cards::Usual.new,
    Cards::Capitalist.new,
    Cards::Virtual.new
  ].freeze

  let(:console) { Console.new }
  let(:garbage) { (0...8).map { rand(65..90).chr }.join }
  let(:app_commands) { ConsoleAppConfig::COMMANDS }

  before do
    allow(STDOUT).to receive(:print).with(UI::USER_INVITE)
    File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
  end

  describe '#console' do
    context 'when correct method calling' do
      before do
        allow(console).to receive(:account_menu)
      end

      after do
        console.run
      end

      it 'create account if input is create' do
        allow(console).to receive_message_chain(:gets, :strip, :downcase) { app_commands[:create] }

        expect(console).to receive(:create_account)
      end

      it 'load account if input is load' do
        allow(console).to receive_message_chain(:gets, :strip, :downcase) { app_commands[:load] }

        expect(console).to receive(:load_account)
      end

      it 'leave app if input is exit' do
        allow(console).to receive_message_chain(:gets, :strip, :downcase) { app_commands[:exit] }

        expect(console).to receive(:exit)
      end

      it 'returns an error if input is something else' do
        allow(STDOUT).to receive(:puts).with(anything)

        allow(console).to receive_message_chain(:gets, :strip, :downcase) { garbage }

        expect(console).to receive(:abort).with(I18n.t('ACCOUNT.ERRORS.INVALID_OPTION'))
      end
    end

    context 'with correct output' do
      it do
        allow(console).to receive_message_chain(:gets, :strip, :downcase) { app_commands[:exit] }
        allow(console).to receive(:exit)
        allow(console).to receive(:account_menu)

        expect(STDOUT).to receive(:puts).with(I18n.t(:WELCOME))
        expect(STDOUT).to receive(:puts).with(I18n.t('ACCOUNT.OPTIONS'))
        expect(STDOUT).to receive(:puts).with(I18n.t(:EXIT_OPTION))

        console.run
      end
    end
  end

  describe '#create' do
    let(:console) { Console.new }

    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }
    let(:success_inputs) { [success_name_input, success_age_input, success_login_input, success_password_input] }

    context 'with success result' do
      before do
        allow(console).to receive_message_chain(:gets, :strip).and_return(*success_inputs)
        allow(console).to receive(:account_menu)
        allow(console).to receive(:accounts).and_return([])

        stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      it 'with correct output' do
        allow(File).to receive(:open)

        ASK_PHRASES.values.each { |phrase| expect(console).to receive(:puts).with(phrase) }

        ACCOUNT_VALIDATION_PHRASES.values.map(&:values).each do |phrase|
          expect(console).not_to receive(:puts).with(phrase)
        end

        console.create_account
      end

      it 'write to file Account instance' do
        console.create_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true

        accounts = YAML.load_file(OVERRIDABLE_FILENAME)

        expect(accounts).to be_a Array
        expect(accounts.size).to be 1

        accounts.map { |account| expect(account).to be_a described_class }
      end
    end

    context 'with errors' do
      before do
        all_inputs = current_inputs + success_inputs

        allow(File).to receive(:open)
        allow(console).to receive_message_chain(:gets, :strip).and_return(*all_inputs)
        allow(console).to receive(:account_menu)
        allow(console).to receive(:accounts).and_return([])

        stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
      end

      context 'with name errors' do
        context 'without small letter' do
          let(:error_input) { 'some_test_name' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:name][:first_letter][3..-1] }
          let(:current_inputs) { [error_input, success_age_input, success_login_input, success_password_input] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with login errors' do
        let(:current_inputs) { [success_name_input, success_age_input, error_input, success_password_input] }

        context 'when present' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:present][3..-1] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 3 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:longer][3..-1] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 21 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:shorter][3..-1] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when exists' do
          let(:error_input) { 'Denis1345' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:login][:exists][3..-1] }

          before do
            allow(AccountValidator).to receive(:accounts) do
              [instance_double('Account', login: error_input)]
            end
          end

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end
      end

      context 'with age errors' do
        let(:current_inputs) { [success_name_input, error_input, success_login_input, success_password_input] }
        let(:error_lower) { ACCOUNT_VALIDATION_PHRASES[:age][:lower][3..-1] }
        let(:error_greater) { ACCOUNT_VALIDATION_PHRASES[:age][:greater][3..-1] }

        context 'with length minimum' do
          let(:error_input) { '22' }

          it { expect { console.create_account }.to output(/#{error_greater}/).to_stdout }
        end

        context 'with length maximum' do
          let(:error_input) { '91' }

          it { expect { console.create_account }.to output(/#{error_lower}/).to_stdout }
        end
      end

      context 'with password errors' do
        let(:current_inputs) { [success_name_input, success_age_input, success_login_input, error_input] }

        context 'when absent' do
          let(:error_input) { '' }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:present][3..-1] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when longer' do
          let(:error_input) { 'E' * 5 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:longer][3..-1] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end

        context 'when shorter' do
          let(:error_input) { 'E' * 31 }
          let(:error) { ACCOUNT_VALIDATION_PHRASES[:password][:shorter][3..-1] }

          it { expect { console.create_account }.to output(/#{error}/).to_stdout }
        end
      end
    end
  end

  describe '#load' do
    context 'without active accounts' do
      it do
        expect(console).to receive(:accounts).and_return([])
        expect(console).to receive(:create_the_first_account).and_return([])

        console.load_account
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(console).to receive_message_chain(:gets, :strip).and_return(*all_inputs)

        allow(AccountValidator).to receive(:accounts) do
          [instance_double('Account', login: login, password: Digest::SHA512.hexdigest(password))]
        end

        allow(console).to receive(:accounts) do
          [instance_double('Account', login: login, password: Digest::SHA512.hexdigest(password))]
        end
      end

      context 'with correct output' do
        let(:all_inputs) { [login, password] }

        it do
          [ASK_PHRASES[:login], ASK_PHRASES[:password]].each do |phrase|
            expect(console).to receive(:puts).with(phrase)
          end

          console.load_account
        end
      end

      context 'when account exists' do
        let(:all_inputs) { [login, password] }

        it do
          expect { console.load_account }.not_to output(/#{ERROR_PHRASES[:user_not_exists]}/).to_stdout
        end
      end

      context 'when account doesn\t exists' do
        let(:all_inputs) { ['test', 'test', login, password] }

        it do
          expect { console.load_account }.to output(/#{ERROR_PHRASES[:user_not_exists][3..-1]}/).to_stdout
        end
      end
    end
  end

  describe '#create_the_first_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }

    it 'with correct output' do
      expect(console).to receive_message_chain(:gets, :strip, :downcase) {}
      expect(console).to receive(:run)

      expect { console.create_the_first_account }.to output {
        show(:FIRST_ACCOUNT_REQUEST, with_invite: true)
      }.to_stdout
    end

    it 'calls create if user inputs is y' do
      expect(console).to receive_message_chain(:gets, :strip, :downcase) { success_input }
      expect(console).to receive(:create_account)

      console.create_the_first_account
    end

    it 'calls console if user inputs is not y' do
      expect(console).to receive_message_chain(:gets, :strip, :downcase) { cancel_input }
      expect(console).to receive(:run)

      console.create_the_first_account
    end
  end

  describe '#account_menu' do
    let(:name) { 'John' }
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account,
        'exit' => :exit
      }
    end

    before do
      allow(console).to receive(:loop).and_yield
    end

    context 'with correct output' do
      it do
        allow(console).to receive(:show_cards)
        allow(console).to receive(:exit)
        allow(console).to receive_message_chain(:gets, :strip).and_return(
          app_commands[:show_cards], app_commands[:exit]
        )

        console.instance_variable_set(:@current_account, instance_double('Account', name: name))

        expect(STDOUT).to receive(:puts).with(I18n.t('ACCOUNT.USER_WELCOME', name: name))
        expect(STDOUT).to receive(:puts).with(I18n.t('ACCOUNT.MENU'))

        console.account_menu
      end
    end

    context 'when commands used' do
      it 'calls specific methods on predefined commands' do
        console.instance_variable_set(:@current_account, instance_double('Account', name: name))

        allow(console).to receive_message_chain(:gets, :strip).and_return(
          app_commands[:show_cards], app_commands[:exit]
        )

        allow(console).to receive(:exit)

        commands.each do |command, method|
          allow(console).to receive_message_chain(:gets, :strip).and_return(command, app_commands[:exit])

          expect(console).to receive(method)

          console.account_menu
        end
      end

      it 'outputs incorrect message on undefined command' do
        allow(console).to receive_message_chain(:gets, :strip).and_return(garbage, app_commands[:exit])

        console.instance_variable_set(:@current_account, instance_double('Account', name: name))

        expect { console.account_menu }.to output(/#{ERROR_PHRASES[:wrong_command][3..-1]}/).to_stdout
      end
    end
  end

  describe '#destroy_account' do
    let(:cancel_input) { 'sdfsdfs' }
    let(:success_input) { 'y' }
    let(:correct_login) { 'test' }
    let(:fake_login) { 'test1' }
    let(:fake_login2) { 'test2' }
    let(:correct_account) { instance_double('Account', login: correct_login) }
    let(:fake_account) { instance_double('Account', login: fake_login) }
    let(:fake_account2) { instance_double('Account', login: fake_login2) }
    let(:accounts) { [correct_account, fake_account, fake_account2] }

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    it 'with correct output' do
      expect(console).to receive_message_chain(:gets, :strip) { '' }
      expect(STDOUT).to receive(:puts).with(I18n.t('ACCOUNT.DESTROY_CONFIRMATION'))

      console.destroy_account
    end

    context 'when deleting' do
      it 'deletes account if user inputs is y' do
        expect(console).to receive_message_chain(:gets, :strip) { success_input }
        expect(described_class).to receive(:accounts) { accounts }

        stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
        console.instance_variable_set(:@current_account, instance_double('Account', login: correct_login))

        console.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be true

        file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)

        expect(file_accounts).to be_a Array

        expect(file_accounts.size).to be 2
      end

      it 'doesnt delete account' do
        expect(console).to receive_message_chain(:gets, :strip) { cancel_input }

        console.destroy_account

        expect(File.exist?(OVERRIDABLE_FILENAME)).to be false
      end
    end
  end

  describe '#show_cards' do
    let(:cards) { [Cards::Usual.new, Cards::Virtual.new] }

    after do
      console.show_cards
    end

    it 'display cards if there are any' do
      console.instance_variable_set(:@current_account, instance_double('Account', cards: cards))

      expect(console).to receive(:puts).with(I18n.t('CARD.AVAILABLE'))

      cards.each_with_index do |card, index|
        type = card.class.to_s.split('::')[1]

        expect(console).to receive(:puts).with("#{card.number}, #{type}, # - #{index + 1}")
      end
    end

    it 'outputs error if there are no active cards' do
      console.instance_variable_set(:@current_account, instance_double('Account', cards: []))

      expect(console).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])
    end
  end

  describe '#create_card' do
    let(:fake_account) do
      AccountBuilder.build do |builder|
        builder.set_name('FakeAccount')
        builder.set_age('30')
        builder.set_login_credentials('fakelogin', 'fakepassword')
        builder.set_empty_cards_list
      end
    end

    before do
      stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
    end

    context 'with correct output' do
      it do
        console.instance_variable_set(:@current_account, instance_double('Account', cards: []))

        allow(console).to receive(:accounts).and_return([])
        allow(File).to receive(:open)
        allow(console.instance_variable_get(:@current_account)).to receive(:cards=)

        expect(STDOUT).to receive(:puts).with(I18n.t('CARD.TYPES'))
        expect(STDOUT).to receive(:puts).with(I18n.t(:EXIT_OPTION))

        expect(console).to receive_message_chain(:gets, :strip).and_return(CARD_TYPES[0])

        console.create_card
      end
    end

    context 'when correct card choose' do
      before do
        allow(fake_account).to receive(:cards).and_return([])
        allow(described_class).to receive(:accounts) { [fake_account] }

        console.instance_variable_set(:@current_account, fake_account)
      end

      after do
        File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
      end

      CARDS.each_with_index do |card, _index|
        it "create card with #{card.class.to_s.split('::')[1]} type" do
          card_type = card.class.to_s.split('::')[1].downcase

          expect(console).to receive_message_chain(:gets, :strip) { card_type }

          console.create_card

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true

          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)

          expect(file_accounts.first.cards.first.class.to_s.split('::')[1].downcase).to eq card_type
          expect(file_accounts.first.cards.first.balance).to eq card.balance
          expect(file_accounts.first.cards.first.number.length).to be 16
        end
      end
    end

    context 'when incorrect card choose' do
      it do
        fake_account.instance_variable_set(:@cards, [])
        console.instance_variable_set(:@current_account, fake_account)

        allow(File).to receive(:open)
        allow(described_class).to receive(:accounts).and_return([])
        allow(console).to receive_message_chain(:gets, :strip).and_return(garbage, CARD_TYPES[0])

        expect { console.create_card }.to output(/#{ERROR_PHRASES[:wrong_card_type]}/).to_stdout
      end
    end
  end

  describe '#destroy_card' do
    let(:fake_account) do
      AccountBuilder.build do |builder|
        builder.set_name('FakeAccount')
        builder.set_age('30')
        builder.set_login_credentials('fakelogin', 'fakepassword')
        builder.set_empty_cards_list
      end
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        console.instance_variable_set(:@current_account, instance_double('Account', cards: []))

        expect(STDOUT).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])

        console.destroy_card
      end
    end

    context 'with cards' do
      let(:card_one) { Cards::Usual.new }
      let(:card_two) { Cards::Capitalist.new }
      let(:fake_cards) { [card_one, card_two] }

      after do
        console.destroy_card
      end

      context 'with correct output' do
        it do
          allow(fake_account).to receive(:cards) { fake_cards }
          console.instance_variable_set(:@current_account, fake_account)

          allow(console).to receive_message_chain(:gets, :strip) { app_commands[:exit] }

          expect(STDOUT).to receive(:puts).with(I18n.t('CARD.CHOOSE'))
          expect(STDOUT).to receive(:puts).with(I18n.t('CARD.AVAILABLE'))
          expect(STDOUT).to receive(:puts).with(I18n.t('EXIT_OPTION'))

          fake_cards.each_with_index do |card, index|
            message = /#{card.number}, #{card.class.to_s.split('::')[1]}, # - #{index + 1}/

            expect(STDOUT).to receive(:puts).with(message)
          end
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(fake_account).to receive(:cards) { fake_cards }
          console.instance_variable_set(:@current_account, fake_account)

          expect(console).to receive_message_chain(:gets, :strip) { app_commands[:exit] }
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(fake_account).to receive(:cards) { fake_cards }
          console.instance_variable_set(:@current_account, fake_account)
          allow(console).to receive(:show_card_choosing_menu)
        end

        it do
          allow(console).to receive_message_chain(:gets, :strip).and_return(fake_cards.length + 1, app_commands[:exit])

          expect { console.destroy_card }.to output((ERROR_PHRASES[:wrong_number]).to_s).to_stdout
        end

        it do
          allow(console).to receive_message_chain(:gets, :strip).and_return(-1, app_commands[:exit])

          expect { console.destroy_card }.to output((ERROR_PHRASES[:wrong_number]).to_s).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:deletable_card_number) { 1 }

        before do
          stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
          fake_account.instance_variable_set(:@cards, fake_cards)

          allow(described_class).to receive(:accounts) { [fake_account] }

          console.instance_variable_set(:@current_account, fake_account)
        end

        after do
          File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
        end

        it 'accept deleting' do
          commands = [deletable_card_number, app_commands[:yes]]

          allow(console).to receive_message_chain(:gets, :strip).and_return(*commands)

          expect { console.destroy_card }.to change { fake_account.cards.size }.by(-1)

          expect(File.exist?(OVERRIDABLE_FILENAME)).to be true

          file_accounts = YAML.load_file(OVERRIDABLE_FILENAME)

          expect(file_accounts.first.cards).not_to include(card_one)
        end

        it 'decline deleting' do
          commands = [deletable_card_number, garbage]
          allow(console).to receive_message_chain(:gets, :strip).and_return(*commands)

          expect { console.destroy_card }.not_to change(fake_account.cards, :size)
        end
      end
    end
  end

  describe '#put_money' do
    let(:fake_account) do
      AccountBuilder.build do |builder|
        builder.set_name('FakeAccount')
        builder.set_age('30')
        builder.set_login_credentials('fakelogin', 'fakepassword')
        builder.set_empty_cards_list
      end
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        console.instance_variable_set(:@current_account, fake_account)

        expect(STDOUT).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])

        console.put_money
      end
    end

    context 'with cards' do
      let(:card_one) { Cards::Usual.new }
      let(:card_two) { Cards::Capitalist.new }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct outout' do
        it do
          allow(fake_account).to receive(:cards) { fake_cards }

          console.instance_variable_set(:@current_account, fake_account)

          allow(console).to receive_message_chain(:gets, :strip) { app_commands[:exit] }

          expect { console.put_money }.to output(/#{I18n.t('CARD.CHOOSE')[3..-3]}/).to_stdout

          fake_cards.each_with_index do |card, index|
            message = /#{card.number}, #{card.class.to_s.split('::')[1]}, # - #{index + 1}/

            expect { console.put_money }.to output(message).to_stdout
          end

          console.put_money
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(fake_account).to receive(:cards) { fake_cards }

          console.instance_variable_set(:@current_account, fake_account)

          expect(console).to receive_message_chain(:gets, :strip) { app_commands[:exit] }

          console.put_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(fake_account).to receive(:cards) { fake_cards }

          console.instance_variable_set(:@current_account, fake_account)
        end

        it do
          allow(console).to receive_message_chain(:gets, :strip).and_return(fake_cards.length + 1, app_commands[:exit])

          expect { console.put_money }.to output(/#{I18n.t('CARD.ERRORS.WRONG_INDEX')[4..-1]}/).to_stdout
        end

        it do
          allow(console).to receive_message_chain(:gets, :strip).and_return(-1, app_commands[:exit])

          expect { console.put_money }.to output(/#{I18n.t('CARD.ERRORS.WRONG_INDEX')[4..-1]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card_one) { Cards::Capitalist.new }
        let(:card_two) { Cards::Capitalist.new }
        let(:fake_cards) { [card_one, card_two] }
        let(:chosen_card_number) { '1' }
        let(:incorrect_money_amount) { '-2' }
        let(:default_balance) { 50.0 }
        let(:correct_money_amount_lower_than_tax) { '5' }
        let(:correct_money_amount_greater_than_tax) { '50' }

        before do
          fake_account.instance_variable_set(:@cards, fake_cards)
          console.instance_variable_set(:@current_account, fake_account)
          console.instance_variable_set(:@operator, Operator.new(fake_account))

          allow(console).to receive(:gets).and_return(*commands)
        end

        context 'with correct output' do
          let(:commands) { [chosen_card_number, incorrect_money_amount, app_commands[:exit]] }

          it do
            expect { console.put_money }.to output(/Input the amount of money you want to put/).to_stdout
          end
        end

        context 'with amount lower then 0' do
          let(:commands) { [chosen_card_number, incorrect_money_amount] }

          it do
            expect { console.put_money }.to output(/You must input correct amount of/).to_stdout
          end
        end

        # rubocop:disable RSpec/NestedGroups
        context 'with amount greater then 0' do
          context 'with tax greater than amount' do
            let(:commands) { [chosen_card_number, correct_money_amount_lower_than_tax] }

            it do
              expect { console.put_money }.to output(/Your tax is higher than input amount/).to_stdout
            end
          end

          context 'with tax lower than amount' do
            let(:custom_cards) do
              [
                Cards::Usual.new(balance: default_balance),
                Cards::Capitalist.new(balance: default_balance),
                Cards::Virtual.new(balance: default_balance)
              ]
            end

            let(:taxes) { [(correct_money_amount_greater_than_tax.to_i * 0.02), 10, 1] }
            let(:commands) { [chosen_card_number, correct_money_amount_greater_than_tax] }

            before do
              allow(described_class).to receive(:accounts) { [fake_account] }

              stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
            end

            after do
              File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
            end

            it do
              custom_cards.each_with_index do |custom_card, index|
                allow(console).to receive(:gets).and_return(*commands)
                fake_account.instance_variable_set(:@cards, [custom_card, card_one, card_two])

                new_balance = default_balance + (correct_money_amount_greater_than_tax.to_i - taxes[index])

                # rubocop:disable Metrics/LineLength
                expect { console.put_money }.to output(
                  /#{correct_money_amount_greater_than_tax}\$ was put on #{custom_card.number}. Balance: #{new_balance}\$. Tax: #{taxes[index]}\$/
                ).to_stdout
                # rubocop:enable Metrics/LineLength

                expect(File.exist?(OVERRIDABLE_FILENAME)).to be true
                expect(YAML.load_file(OVERRIDABLE_FILENAME).first.cards.first.balance).to eq(new_balance)
              end
            end
          end
          # rubocop:enable RSpec/NestedGroups
        end
      end
    end
  end

  describe '#withdraw_money' do
    let(:fake_account) do
      AccountBuilder.build do |builder|
        builder.set_name('FakeAccount')
        builder.set_age('30')
        builder.set_login_credentials('fakelogin', 'fakepassword')
        builder.set_empty_cards_list
      end
    end

    before do
      stub_const('ConsoleAppConfig::ACCOUNTS_PATH', OVERRIDABLE_FILENAME)
    end

    after do
      File.delete(OVERRIDABLE_FILENAME) if File.exist?(OVERRIDABLE_FILENAME)
    end

    context 'without cards' do
      it 'shows message about not active cards' do
        console.instance_variable_set(:@current_account, instance_double('Account', cards: []))

        expect(STDOUT).to receive(:puts).with(ERROR_PHRASES[:no_active_cards])

        console.withdraw_money
      end
    end

    context 'with cards' do
      let(:card_one) { Cards::Capitalist.new }
      let(:card_two) { Cards::Capitalist.new }
      let(:fake_cards) { [card_one, card_two] }

      context 'with correct output' do
        it do
          allow(fake_account).to receive(:cards) { fake_cards }

          console.instance_variable_set(:@current_account, fake_account)

          allow(console).to receive_message_chain(:gets, :strip) { app_commands[:exit] }

          fake_cards.each_with_index do |card, index|
            message = /#{card.number}, #{card.class.to_s.split('::')[1]}, # - #{index + 1}/

            expect { console.withdraw_money }.to output(message).to_stdout
          end
        end
      end

      context 'when exit if first gets is exit' do
        it do
          allow(fake_account).to receive(:cards) { fake_cards }

          console.instance_variable_set(:@current_account, fake_account)

          expect(console).to receive_message_chain(:gets, :strip) { app_commands[:exit] }

          console.withdraw_money
        end
      end

      context 'with incorrect input of card number' do
        before do
          allow(fake_account).to receive(:cards) { fake_cards }

          console.instance_variable_set(:@current_account, fake_account)
        end

        after do
          console.withdraw_money
        end

        it do
          allow(console).to receive_message_chain(:gets, :strip).and_return(fake_cards.length + 1, app_commands[:exit])

          expect { console.withdraw_money }.to output(/#{I18n.t('CARD.ERRORS.WRONG_INDEX')[4..-1]}/).to_stdout
        end

        it do
          allow(console).to receive_message_chain(:gets, :strip).and_return(-1, 'exit')

          expect { console.withdraw_money }.to output(/#{I18n.t('CARD.ERRORS.WRONG_INDEX')[4..-1]}/).to_stdout
        end
      end

      context 'with correct input of card number' do
        let(:card) { Cards::Usual.new }
        let(:chosen_card_number) { '1' }
        let(:default_balance) { '10' }

        before do
          console.instance_variable_set(:@current_account, fake_account)
          fake_account.instance_variable_set(:@cards, [card])
          console.instance_variable_set(:@operator, Operator.new(fake_account))

          allow(console).to receive(:gets).and_return(
            chosen_card_number,
            default_balance,
            app_commands[:exit]
          )
        end

        it { expect { console.withdraw_money }.to output(/Input the amount of money you want to withdraw/).to_stdout }
      end
    end
  end
end
