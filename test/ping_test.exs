defmodule BankAccount do
  def start do
    await([])
  end

  def await(events) do
    receive do
      {:check_balance, pid} -> divulge_balance(pid, events)
      {:deposit, amount}    -> events = deposit(amount, events)
      {:withdrawal, amount} -> events = withdraw(amount, events)
    end
    await(events)  # <- recursive call to keep it running for multiple inquiries
  end

  defp deposit(amount, events) do
    # return events with a new deposit
    events ++ [{:deposit, amount}]
  end

  defp withdraw(amount, events) do
    # events ++ [{:withdraw, amount * -1}]
    events ++ [{:withdrawal, amount}]
  end

  defp divulge_balance(pid, events) do
    send pid, {:balance, calculate_balance(events)}
  end

  defp calculate_balance(events) do
    deposits = sum(just_deposits(events))
    withdrawals = sum(just_withrawals(events))
    deposits - withdrawals
  end

  defp just_deposits(events) do
    just_type(events, :deposit)
  end

  defp just_withrawals(events) do
    just_type(events, :withdrawal)
  end

  defp just_type(events, expected_type) do
    Enum.filter(events, fn({type, _}) -> type == expected_type end)
  end

  defp sum(events) do
    # Enum.reduce(Events, 0, fn({_, amount}, acc) -> acc + amount end)
    Enum.reduce(events, 0, fn({_, amount}, acc) -> acc + amount end)  # Events vs events typo
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

  test "balance is incremented by the amount deposited" do
    account = spawn_link(BankAccount, :start, [])
    send account, {:deposit, 10}
    verify_balance_is 10, account
  end

  test "balance is decremented by the amount of a withdrawal" do
    account = spawn_link(BankAccount, :start, [])
    send account, {:deposit, 20}
    send account, {:withdrawal, 10}
    verify_balance_is 10, account
  end

  def verify_balance_is(expected_balance, account) do
    send account, {:check_balance, self}
    assert_receive {:balance, ^expected_balance} # the ^ is required when passing a variable to a function rather than a value
  end
end
