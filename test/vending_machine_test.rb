require "minitest/autorun"
require_relative "./test_helper"
require_relative "../vending_machine"

class VendingMachineTest < Minitest::Test
  def setup
    @vending_machine = VendingMachine.new
  end

  def test_初期状態でコーラを5つ格納できる
    vending_machine = VendingMachine.new(stocks: {'コーラ' => {price: 120, count: 5}})
    assert_equal 5, vending_machine.stocks['コーラ'][:count]
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

    assert_equal 150, @vending_machine.total_money_amount
  end

  def test_投入金額の総計を釣り銭として出力すること
    @vending_machine.insert_money(1_000)
    @vending_machine.insert_money(500)
    @vending_machine.insert_money(100)

    assert_equal 1_600, @vending_machine.refund, 1_600
    assert_equal 0, @vending_machine.total_money_amount
  end

  def test_格納されているジュースの情報を取得できる
    vending_machine = VendingMachine.new(stocks: {'コーラ' => {price: 120, count: 5}})

    assert_equal ({"コーラ" => {price: 120, count: 5}}), vending_machine.stocks
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
end
