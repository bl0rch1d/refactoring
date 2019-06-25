# frozen_string_literal: true

module Cards
  class Base
    NUMBER_LENGTH = 16

    attr_accessor :balance
    attr_reader :number, :taxes

    class << self
      include UI

      def generate_number
        Array.new(NUMBER_LENGTH) { rand(10) }.join
      end

      def withdraw_money(account, card, amount, send_context: false)
        tax = send_context ? card.send_tax(amount) : card.withdraw_tax(amount)

        return show('OPERATOR.ERRORS.NOT_ENOUGH_MONEY') unless TransactionValidator.amount_valid?(card, amount, tax)

        card.balance -= (amount + tax)

        Account.update account

        show('OPERATOR.WITHDRAW', amount: amount, card_number: card.number, card_balance: card.balance, tax: tax)
      end

      def put_money(account, card, amount)
        tax = card.put_tax(amount)

        return show('OPERATOR.ERRORS.HIGH_TAX') unless TransactionValidator.tax_valid?(amount, tax)

        card.balance += (amount - tax)

        Account.update account

        show('OPERATOR.PUT', amount: amount, card_number: card.number, card_balance: card.balance, tax: tax)
      end

      def send_money(sender_account, sender_card, recipient_data, amount)
        recipient_card = recipient_data[:account].cards.detect { |card| card.number == recipient_data[:card_number] }

        withdraw_money(sender_account, sender_card, amount, send_context: true)

        put_money(recipient_data[:account], recipient_card, amount)
      end
    end

    def initialize(_balance)
      @number = self.class.generate_number
    end

    private

    def calculate_tax(amount, percent_tax, fixed_tax)
      (amount / 100) * percent_tax + fixed_tax
    end

    def put_fixed
      0
    end

    def put_percent
      0
    end

    def withdraw_fixed
      0
    end

    def withdraw_percent
      0
    end

    def send_fixed
      0
    end

    def send_percent
      0
    end
  end
end
