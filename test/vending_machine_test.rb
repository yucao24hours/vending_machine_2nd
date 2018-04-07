require "minitest/autorun"
require_relative "./test_helper"
require_relative "../vending_machine"

class VendingMachineTest < Minitest::Test
  def setup
    @vending_machine = VendingMachine.new
  end

  def test_許容された金種のみ投入できること
    assert @vending_machine.insert_money(10)
    assert @vending_machine.insert_money(50)
    assert @vending_machine.insert_money(100)
    assert @vending_machine.insert_money(500)
    assert @vending_machine.insert_money(1_000)
  end

  def test_投入金額の総計を取得できること
    @vending_machine.insert_money(100)
    @vending_machine.insert_money(50)

    assert_equal @vending_machine.total_money_amount, 150
  end

  def test_投入金額の総計を釣り銭として出力すること
    @vending_machine.insert_money(1_000)
    @vending_machine.insert_money(500)
    @vending_machine.insert_money(100)

    assert_equal @vending_machine.refund, 1_600
    assert_equal @vending_machine.total_money_amount, 0
  end
end
