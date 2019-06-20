# frozen_string_literal: true

module Cards
  class Base
    NUMBER_LENGTH = 16

    attr_accessor :balance
    attr_reader :number, :taxes

    def self.generate_number
      Array.new(NUMBER_LENGTH) { rand(10) }.join
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
