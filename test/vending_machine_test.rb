require "minitest/autorun"
require_relative "./test_helper"
require_relative "../vending_machine"

class VendingMachineTest < Minitest::Test
  def setup
    @vending_machine = VendingMachine.new
  end

  def test_許容する金種が限られていること
    assert @vending_machine.acceptable_money?(10)
    assert @vending_machine.acceptable_money?(50)
    assert @vending_machine.acceptable_money?(100)
    assert @vending_machine.acceptable_money?(500)
    assert @vending_machine.acceptable_money?(1_000)
  end
end
