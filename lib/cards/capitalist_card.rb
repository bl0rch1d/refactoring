# frozen_string_literal: true

module Cards
  class Capitalist < Base
    def initialize(balance: 100)
      super

      @balance = balance

      @taxes = {
        withdraw: 0.04,
        put: 10,
        send: 0.1
      }
    end
  end
end
