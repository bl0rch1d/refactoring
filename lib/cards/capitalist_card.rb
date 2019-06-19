# frozen_string_literal: true

module Cards
  class Capitalist < Base
    def initialize(balance: 100)
      super

      @balance = balance
    end

    # --- Variant 2 ---
    def withdraw_tax(amount)
      amount * 0.04
    end

    def put_tax(_amount)
      10
    end

    def send_tax(amount)
      amount * 0.1
    end
  end
end
