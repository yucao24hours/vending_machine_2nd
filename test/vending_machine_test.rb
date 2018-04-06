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
end
