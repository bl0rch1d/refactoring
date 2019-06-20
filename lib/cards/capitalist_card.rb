# frozen_string_literal: true

module Cards
  class Capitalist < Base
    def initialize(balance: 100)
      super

      @balance = balance
    end

    def withdraw_tax(amount)
      calculate_tax(amount, withdraw_percent, withdraw_fixed)
    end

    def put_tax(amount)
      calculate_tax(amount, put_percent, put_fixed)
    end

    def send_tax(amount)
      calculate_tax(amount, send_percent, send_fixed)
    end

    private

    def withdraw_percent
      4
    end

    def put_fixed
      10
    end

    def send_percent
      10
    end
  end
end
