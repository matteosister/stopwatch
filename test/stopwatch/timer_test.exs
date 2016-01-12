defmodule Stopwatch.TimerTest do
  use ExUnit.Case
  use Stopwatch

  setup do
    Timer.clear
  end

  test "count empty is 0" do
    assert 0 === Timer.count
  end

  test "count after insert is 1" do
    Timer.start :test
    assert 1 === Timer.count
  end

  test "count after insert and stop is 0" do
    Timer.start :test
    Timer.stop :test
    assert 0 === Timer.count
  end
end
