defmodule Stopwatch.WatchTest do
  use ExUnit.Case, async: true
  use Stopwatch
  use Timex

  test "new timer" do
    time = Time.zero
    assert %Watch{name: :test, start_time: time} === Watch.new(:test, time)
  end

  test "total time with unfinished timer" do
    watch = Watch.new(:test, Time.zero)
    assert is_tuple(Watch.total_time(watch))
  end

  test "total time with finished timer" do
    watch = Watch.new(:test, Time.zero) |> Watch.stop({0, 1, 1})
    assert {0, 1, 1} === Watch.total_time(watch)
  end
end
