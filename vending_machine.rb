class VendingMachine
  ACCEPTABLE_MONEY = [10, 50, 100, 500, 1_000].freeze

  attr_reader :total_money_amount

  def initialize
    @total_money_amount = 0
  end

  def insert_money(money)
    return nil unless ACCEPTABLE_MONEY.include?(money)

    @total_money_amount += money
  end
end
