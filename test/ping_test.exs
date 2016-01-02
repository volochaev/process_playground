defmodule BankAccount do
  def start do
    await
  end

  def await do
    receive do
      # {:check_balance, pid} -> send pid, {:balance, 0}
      {:check_balance, pid} -> divulge_balance(pid)
    end
    await  # <- recursive call to keep it running for multiple inquiries
  end

  def divulge_balance(pid) do
    # pid <- {:balance, 0}  <-- that's the deprecated syntax
    send pid, {:balance, 0} # this is what the send function looks like now
  end
end

defmodule BankAccountTest do
  use ExUnit.Case

  test "the truth" do
    assert(true)
  end

  test "starting balance is 0" do
    # balance = 0
    # assert(balance == 0)
    account = spawn_link(BankAccount, :start, [])
    verify_balance_is 0, account
  end

  def verify_balance_is(expected_balance, account) do
    send account, {:check_balance, self}
    assert_receive {:balance, ^expected_balance} # the ^ is required when passing a variable to a function rather than a value
  end
end
