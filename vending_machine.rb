require "pry"

class VendingMachine
  ACCEPTABLE_MONEY = [10, 50, 100, 500, 1_000].freeze

  attr_reader :stocks, :total_money_amount

  def initialize(stocks: nil)
    @total_money_amount = 0
    # stocsk は
    # {
    #   {'コーラ' => {price: 120, count: 5}},
    #   {'オレンジジュース' => {price: 100, count: 2}},
    #   {'エナジードリンク' => {price: 200, count: 4}}
    # }
    # のようなハッシュでもってみる
    @stocks = stocks
  end

  def insert_money(money)
    return money unless ACCEPTABLE_MONEY.include?(money)

    @total_money_amount += money
  end

  def refund
    change = @total_money_amount
    @total_money_amount = 0

    change
  end

  def sell(drink_name)
    if can_buy?(drink_name)
      stocks[drink_name][:count] -= 1
    end
  end

  private

  def can_buy?(drink_name)
    return false unless stocks

    price = stocks[drink_name][:price]
    count = stocks[drink_name][:count]

    (total_money_amount >= price) && (count >= 1)
  end
end
