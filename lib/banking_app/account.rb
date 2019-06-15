# frozen_string_literal: true

class Account
  prepend ConsoleAppConfig
  prepend UI
  extend DBHelper

  attr_accessor :name, :age, :login, :password, :cards

  def self.add(account)
    save accounts << account
  end

  def self.update(account_to_update)
    save accounts.map { |account| account.login == account_to_update.login ? account_to_update : account }.compact
  end

  def self.destroy(account_to_delete)
    save accounts.map { |account| account if account.login != account_to_delete.login }.compact
  end

  # def put_money
  #   puts 'Choose the card for putting:'

  #   if @current_account.card.any?
  #     @current_account.card.each_with_index do |c, i|
  #       puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
  #     end
  #     puts "press `exit` to exit\n"
  #     loop do
  #       answer = gets.chomp
  #       break if answer == 'exit'
  #       if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
  #         current_card = @current_account.card[answer&.to_i.to_i - 1]
  #         loop do
  #           puts 'Input the amount of money you want to put on your card'
  #           a2 = gets.chomp
  #           if a2&.to_i.to_i > 0
  #             if put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
  #               puts 'Your tax is higher than input amount'
  #               return
  #             else
  #               new_money_amount = current_card[:balance] + a2&.to_i.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
  #               current_card[:balance] = new_money_amount
  #               @current_account.card[answer&.to_i.to_i - 1] = current_card
  #               new_accounts = []
  #               accounts.each do |ac|
  #                 if ac.login == @current_account.login
  #                   new_accounts.push(@current_account)
  #                 else
  #                   new_accounts.push(ac)
  #                 end
  #               end
  #               File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
  #               puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
  #               return
  #             end
  #           else
  #             puts 'You must input correct amount of money'
  #             return
  #           end
  #         end
  #       else
  #         puts "You entered wrong number!\n"
  #         return
  #       end
  #     end
  #   else
  #     puts "There is no active cards!\n"
  #   end
  # end

  # private

  # def self.withdraw_tax(card_type:, amount:)
  #   case card_type
  #   when 'usual'      then amount * 0.05
  #   when 'capitalist' then amount * 0.04
  #   when 'virtual'    then amount * 0.88
  #   end

  # if type == 'usual'
  #   return amount * 0.05
  # elsif type == 'capitalist'
  #   return amount * 0.04
  # elsif type == 'virtual'
  #   return amount * 0.88
  # end
  # 0
  # end

  # def put_tax(type, balance, number, amount)
  #   if type == 'usual'
  #     return amount * 0.02
  #   elsif type == 'capitalist'
  #     return 10
  #   elsif type == 'virtual'
  #     return 1
  #   end
  #   0
  # end

  # def sender_tax(type, balance, number, amount)
  #   if type == 'usual'
  #     return 20
  #   elsif type == 'capitalist'
  #     return amount * 0.1
  #   elsif type == 'virtual'
  #     return 1
  #   end
  #   0
  # end
end
