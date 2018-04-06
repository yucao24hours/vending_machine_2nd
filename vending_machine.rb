class VendingMachine
  ACCEPTABLE_MONEY = [10, 50, 100, 500, 1_000]

  def acceptable_money?(money)
    ACCEPTABLE_MONEY.include?(money)
  end
end
