# frozen_string_literal: true

module Cards
  class Virtual < Base
    def initialize(balance: 150)
      super

      @balance = balance

      @taxes = {
        withdraw: 0.88,
        put: 1,
        send: 1
      }
    end
  end
end
