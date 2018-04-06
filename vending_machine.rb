class VendingMachine
  ACCEPTABLE_MONEY = [10, 50, 100, 500, 1_000]

  def insert_money(money)
    return nil unless acceptable_money?(money)

    true
  end

  private

  def acceptable_money?(money)
    ACCEPTABLE_MONEY.include?(money)
  end
end
