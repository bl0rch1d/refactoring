# frozen_string_literal: true

require 'yaml'
require 'pry'
require 'digest'

require_relative 'ui'
require_relative '../helpers/db'

class Account
  include UI
  extend DBHelper

  attr_accessor :name, :age, :login, :password, :cards

  def destroy_card
    Card.destroy(@current_account)

    update
  end

  # def remove_card(card_to_delete)
  #   return puts "You entered wrong number!\n" unless card_to_delete <= @current_account.cards.length && card_to_delete.positive?

  #   puts "Are you sure you want to delete #{@current_account.cards[card_to_delete - 1].number}?[y/n]"

  #   reply = gets.strip.downcase

  #   return if reply == 'n'

  #   if reply == 'y'
  #     @current_account.cards.delete_at(card_to_delete&.to_i.to_i - 1)
  #     update
  #   end
  # end

  def self.update(account)
    new_accounts = []

    accounts.each do |ac|
      if ac.login == account.login
        new_accounts.push(account)
      else
        new_accounts.push(ac)
      end
    end

    File.open(ACCOUNTS_PATH, 'w') { |f| f.write new_accounts.to_yaml } # Storing
  end

  def choose_card
    return puts "There is no active cards!\n" unless @current_account.cards.any?

    @current_account.cards.each_with_index do |card, i|
      puts "- #{card.number}, #{card.type}, press #{i + 1}"
    end

    puts "press `exit` to exit\n"

    loop do
      card_number_reply = gets.strip
      break if card_number_reply == 'exit'

      return puts "You entered wrong number!\n" unless card_number_reply&.to_i.to_i <= @current_account.cards.length && card_number_reply&.to_i.to_i > 0

      return @current_account.cards[card_number_reply&.to_i.to_i - 1]
    end
  end

  def withdraw_money
    puts 'Choose the card for withdrawing:'

    current_card = choose_card

    p '------------------------------------'
    p current_card

    return unless current_card

    loop do
      puts 'Input the amount of money you want to withdraw'
      money_reply = gets.strip

      return puts 'You must input correct amount of $' unless money_reply&.to_i.to_i > 0

      money_left = current_card[:balance] - money_reply&.to_i.to_i - withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], money_reply&.to_i.to_i)

      return puts "You don't have enough money on card for such operation" unless money_left > 0

      current_card[:balance] = money_left
      @current_account.cards[current_card[:number]] = current_card
      new_accounts = []

      accounts.each do |ac|
        if ac.login == @current_account.login
          new_accounts.push(@current_account)
        else
          new_accounts.push(ac)
        end
      end

      File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing

      puts "Money #{money_reply&.to_i.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], money_reply&.to_i.to_i)}$"

      return
    end
  end

  def put_money
    puts 'Choose the card for putting:'

    return puts "There is no active cards!\n" unless @current_account.cards.any?

    @current_account.cards.each_with_index do |c, i|
      puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
    end

    puts "press `exit` to exit\n"

    loop do
      card_number_reply = gets.strip
      break if card_number_reply == 'exit'

      return puts "You entered wrong number!\n" unless card_number_reply&.to_i.to_i <= @current_account.cards.length && card_number_reply&.to_i.to_i > 0

      current_card = @current_account.cards[card_number_reply&.to_i.to_i - 1]

      loop do
        puts 'Input the amount of money you want to put on your card'
        a2 = gets.strip

        return puts 'You must input correct amount of money' unless a2&.to_i.to_i > 0

        return puts 'Your tax is higher than input amount' if put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i

        new_money_amount = current_card[:balance] + a2&.to_i.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
        current_card[:balance] = new_money_amount
        @current_account.cards[card_number_reply&.to_i.to_i - 1] = current_card
        new_accounts = []
        accounts.each do |ac|
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
        end
        File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
        puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
        return
      end
    end
  end

  def self.destroy(account)
    new_accounts = []

    accounts.each do |ac|
      if ac.login == account.login
      else
        new_accounts.push(ac)
      end
    end

    File.open(ACCOUNTS_PATH, 'w') { |f| f.write new_accounts.to_yaml } # Storing
  end

  private

  # def accounts
  #   if File.exist?('accounts.yml')
  #     YAML.load_file('accounts.yml')
  #   else
  #     []
  #   end
  # end

  def withdraw_tax(type, _balance, _number, amount)
    if type == 'usual'
      return amount * 0.05
    elsif type == 'capitalist'
      return amount * 0.04
    elsif type == 'virtual'
      return amount * 0.88
    end

    0
  end

  def put_tax(type, _balance, _number, amount)
    if type == 'usual'
      return amount * 0.02
    elsif type == 'capitalist'
      return 10
    elsif type == 'virtual'
      return 1
    end

    0
  end

  def sender_tax(type, _balance, _number, amount)
    if type == 'usual'
      return 20
    elsif type == 'capitalist'
      return amount * 0.1
    elsif type == 'virtual'
      return 1
    end

    0
  end
end
