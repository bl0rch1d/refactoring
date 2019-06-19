# frozen_string_literal: true

module Cards
  class Usual < Base
    def initialize(balance: 50)
      super

      @balance = balance
    end

    def withdraw_tax(amount)
      amount * 0.05
    end

    def put_tax(amount)
      amount * 0.02
    end

    def send_tax(_amount)
      20
    end
  end
end
