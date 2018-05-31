require "pry"

class VendingMachine
  ACCEPTABLE_MONEY = [10, 50, 100, 500, 1_000].freeze
  CHANGE_STOCK_COUNT = 10

  # stocks: 現在の在庫
  # total_money: 現在の投入金種
  # sales_amount: 売上金額合計
  attr_reader :total_money, :sales_amount, :change_stock
  attr_writer :stocks

  def initialize(stocks: {})
    @total_money = {"10" => 0, "50" => 0, "100" => 0, "500" => 0, "1000" => 0}
    # stocsk は
    # {
    #   {'コーラ' => {price: 120, count: 5}},
    #   {'オレンジジュース' => {price: 100, count: 2}},
    #   {'エナジードリンク' => {price: 200, count: 4}}
    # }
    # のようなハッシュでもってみる
    @stocks = stocks.dup
    @sales_amount = 0
    # change_stock は、金種をキー、枚数を値として持つハッシュ。
    # {
    #   '10' => 10,
    #   '50' => 10,
    #   ...
    # }
    @change_stock = ACCEPTABLE_MONEY.each_with_object({}) do |money, memo|
      memo[money.to_s] = CHANGE_STOCK_COUNT
    end
  end

  def stocks
    @stocks.dup
  end

  def insert_money(money)
    return money unless ACCEPTABLE_MONEY.include?(money)

    @total_money[money.to_s] += 1
  end

  def total_money_amount
    @total_money.inject(0) do |memo, money|
      memo + (money[0].to_i * money[1])
    end
  end

  def refund
    change = total_money_amount

    # total_money 分だけ
    # change_stock を増やさないとならない。
    # （total_money はただの金額のメモで、お金の一時保管所ではない）
    # 今の insert の方法だと金額しかとってなくて、
    # 何円玉を何枚、っていうのはわからないので
    # 10 * 10 で 100 円か、100 * 1 で 100 円なのかがわからない。
    # そうなると、total_money も金種ごとにもたないとだめかも

    if @total_money != 0
      ACCEPTABLE_MONEY.sort{|elem1, elem2| elem2 <=> elem1 }.each do |acceptable_money|
        if @total_money >= acceptable_money
          reduce_change_stock_of(acceptable_money)
        end
      end
    end

    change
  end

  def sell(drink_name)
    if can_buy?(drink_name)
      drink_price = @stocks[drink_name][:price].dup

      @stocks[drink_name][:count] -= 1
      @sales_amount += drink_price
      ACCEPTABLE_MONEY.sort{|elem1, elem2| elem2 <=> elem1 }.each do |acceptable_money|
        if drink_price >= acceptable_money
          reduce_total_money(acceptable_money, drink_price)
        end
      end

      total_money_amount
    end
  end

  def add_stock(drink)
    @stocks = @stocks.merge(drink)
  end

  def buyable_drinks
    # XXX インデックスでアクセスするのがダサいしわかりづらく感じる
    @stocks.each_with_object([]) do |drink, memo|
      memo << drink[0] if drink[1][:price] <= @total_money
    end
  end

  private

  def can_buy?(drink_name)
    return false unless @stocks

    price = @stocks[drink_name][:price]
    count = @stocks[drink_name][:count]

    (total_money_amount >= price) && (count >= 1)
  end

  def reduce_total_money(acceptable_money, drink_price)
    @total_money[acceptable_money.to_s] -= 1
    drink_price -= acceptable_money

    reduce_total_money(acceptable_money, drink_price) \
      if drink_price >= acceptable_money
  end

  def reduce_change_stock_of(acceptable_money)
    @change_stock[acceptable_money.to_s] -= 1
    @total_money -= acceptable_money

    reduce_change_stock_of(acceptable_money) \
      if @total_money >= acceptable_money && @change_stock[acceptable_money.to_s] > 0
  end
end
