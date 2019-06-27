# frozen_string_literal: true

module Cards
  class Usual < Base
    def initialize(balance: 50)
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
      5
    end

    def put_percent
      2
    end

    def send_fixed
      20
    end
  end
end
