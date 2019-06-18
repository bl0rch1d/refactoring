# frozen_string_literal: true

module Cards
  class Usual < Base
    def initialize(balance: 50)
      super

      @balance = balance

      @taxes = {
        withdraw: 0.05,
        put: 0.02,
        send: 20
      }
    end
  end
end
