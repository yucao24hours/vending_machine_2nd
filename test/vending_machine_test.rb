require "minitest/autorun"
require_relative "./test_helper"
require_relative "../vending_machine"

class VendingMachineTest < Minitest::Test
  def setup
    @vending_machine = VendingMachine.new(stocks: {'コーラ' => {price: 120, count: 5}})
  end

  def test_初期状態では総売上金額は0円になっていること
    assert_equal 0, @vending_machine.sales_amount
  end

  def test_初期状態でコーラを5つ格納していること
    assert_equal 5, @vending_machine.stocks['コーラ'][:count]
  end

  def test_許容されていない金種が投入されたら釣り銭として返すこと
    assert_equal 10_000, @vending_machine.insert_money(10_000)
  end

  def test_許容されていない金種が投入されたら投入総額には加算しないこと
    @vending_machine.insert_money(10_000)

    assert_equal @vending_machine.total_money_amount, 0
  end

  def test_許容された金種のみ投入できること
    @vending_machine.insert_money(10)
    assert_equal 10, @vending_machine.total_money_amount

    @vending_machine.insert_money(50)
    assert_equal 60, @vending_machine.total_money_amount

    @vending_machine.insert_money(100)
    assert_equal 160, @vending_machine.total_money_amount

    @vending_machine.insert_money(500)
    assert_equal 660, @vending_machine.total_money_amount

    @vending_machine.insert_money(1_000)
    assert_equal 1_660, @vending_machine.total_money_amount
  end

  def test_投入金額の総計を取得できること
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(50)

    assert_equal 150, @vending_machine.change_amount
  end

  def test_投入金額の総計を釣り銭として出力すること
    @vending_machine.insert_money(1_000)
    @vending_machine.insert_money(500)
    @vending_machine.insert_money(100)

    assert_equal 1_600, @vending_machine.refund
    assert_equal 0, @vending_machine.total_money_amount
  end

  def test_格納されているジュースの情報を取得できる
    assert_equal ({"コーラ" => {price: 120, count: 5}}), @vending_machine.stocks
  end

  def test_ジュースの値段以上の金額を投入されると、販売したとしてジュースの在庫を減らすこと
    vending_machine = VendingMachine.new(stocks: {'コーラ' => {price: 120, count: 1}})
    assert_equal 1, vending_machine.stocks['コーラ'][:count]

    vending_machine.insert_money(100)
    vending_machine.insert_money(10)
    vending_machine.insert_money(10)
    vending_machine.sell('コーラ')

    assert_equal 0, vending_machine.stocks['コーラ'][:count]
  end

  def test_ジュースの値段以上の金額を投入されると、販売したとして売上金を増やすこと
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(10)
    @vending_machine.insert_money(10)
    @vending_machine.sell('コーラ')

    assert_equal 120, @vending_machine.sales_amount
  end

  def test_ジュースの値段以下の金額を投入されると、ジュースの在庫を減らさないこと
    vending_machine = VendingMachine.new(stocks: {'コーラ' => {price: 120, count: 1}})
    assert_equal 1, vending_machine.stocks['コーラ'][:count]

    vending_machine.insert_money(100)
    vending_machine.insert_money(10)
    vending_machine.sell('コーラ')

    assert_equal 1, vending_machine.stocks['コーラ'][:count]
  end

  def test_ジュースの値段以下の金額を投入されると、売上金を増やさないこと
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(10)
    @vending_machine.sell('コーラ')

    assert_equal 0, @vending_machine.sales_amount
  end

  def test_払い戻しをすると投入金額から購入金額を引いた残りが返される
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(100)
    @vending_machine.sell('コーラ')

    assert_equal 80, @vending_machine.refund
  end

  def test_在庫を追加できる
    @vending_machine.add_stock({'レッドブル' => {price: 200, count: 5}})
    @vending_machine.add_stock({'水' => {price: 100, count: 5}})

    assert_equal 5, @vending_machine.stocks['レッドブル'][:count]
    assert_equal 5, @vending_machine.stocks['水'][:count]
  end

  def test_投入金額、在庫の点で購入可能なドリンクのリストを取得できる
    @vending_machine.add_stock({'水' => {price: 100, count: 1}})

    @vending_machine.insert_money(100)

    assert_equal ['水'], @vending_machine.buyable_drinks
  end

  def test_ジュース値段以上の投入金額が投入されている条件下で購入操作を行うと、釣り銭（投入金額とジュース値段の差分）を出力する
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(10)
    @vending_machine.insert_money(10)

    assert_equal 0, @vending_machine.sell('コーラ')
  end

  def test_釣り銭ストックとして、有効なお札と硬貨10枚ずつを保持すること
    assert_equal 10, @vending_machine.change_stock['10']
    assert_equal 10, @vending_machine.change_stock['50']
    assert_equal 10, @vending_machine.change_stock['100']
    assert_equal 10, @vending_machine.change_stock['500']
    assert_equal 10, @vending_machine.change_stock['1000']
  end

  def test_釣り銭ストックは大きい金種から使われること
    @vending_machine.insert_money(1000)
    @vending_machine.sell('コーラ')

    @vending_machine.refund

    assert_equal 9, @vending_machine.change_stock['500']
    assert_equal 7, @vending_machine.change_stock['100']
    assert_equal 9, @vending_machine.change_stock['50']
    assert_equal 7, @vending_machine.change_stock['10']
  end

  def test_ストックからなくなった硬貨は、他の硬貨で補うこと
    @vending_machine.add_stock({'水' => {price: 100, count: 5}})

    3.times do
      @vending_machine.insert_money(1000)
      @vending_machine.sell('コーラ')
      @vending_machine.refund
    end

    # この時点で、釣り銭ストックは
    # @change_stock={"10"=>1, "50"=>7, "100"=>1, "500"=>7, "1000"=>10}

    @vending_machine.insert_money(1000)
    @vending_machine.sell('水') # お釣りが 900 円発生する => 100 円玉が 3 枚足りない！ => 50 円玉を 6 枚使って補う
    @vending_machine.refund

    assert_equal 1, @vending_machine.change_stock['50']
  end

  def test_投入したお金も釣り銭ストックに加えられること
    # 120 円のコーラを買うのにわざと 130 円入れる
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(10)
    @vending_machine.insert_money(10)
    @vending_machine.insert_money(10)
    @vending_machine.sell('コーラ')

    assert_equal 12, @vending_machine.change_stock['10']
  end
end
