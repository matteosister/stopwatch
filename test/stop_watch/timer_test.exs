defmodule StopWatch.TimerTest do
  use ExUnit.Case, async: true
  use StopWatch
  use Timex

  test "new timer" do
    time = Time.zero
    assert %Timer{start: time} === Timer.new(time)
  end

  test "total time with unfinished timer" do
    timer = Timer.new(Time.zero)
    assert is_tuple(Timer.total_time(timer))
  end
end
