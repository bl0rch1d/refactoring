# frozen_string_literal: true

module Cards
  class Virtual < Base
    def initialize(balance: 150)
      super

      @balance = balance
    end

    def withdraw_tax(amount)
      amount * 0.88
    end

    def put_tax(_amount)
      1
    end

    def send_tax(_amount)
      1
    end
  end
end
