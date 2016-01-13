defmodule Stopwatch.WatchTest do
  use ExUnit.Case, async: false
  doctest Stopwatch.Watch
  use Stopwatch
  use Timex
  import Mock

  test "new timer" do
    time = Time.zero
    assert %Watch{start_time: time} === Watch.new(time)
  end

  test "total time with unfinished timer" do
    watch = Watch.new(Time.zero)
    assert is_integer(Watch.total_time(watch))
  end

  test "total time with finished timer" do
    watch = Watch.new(Time.zero) |> Watch.stop({0, 1, 1})
    assert 1000 === Watch.total_time(watch)
  end

  # I need to mock the Time.now function to know what the result will be
  test_with_mock "laps", Timex.Time, [now: fn -> {1, 0, 2} end] do
    w = Timer.start
    w = Timer.lap(w, "lap 1")
    w = Timer.lap(w, "lap 2")
    assert Watch.laps(w) === [{"lap 1", {1, 0, 2}}, {"lap 2", {1, 0, 2}}]
  end

  # I need to mock the Time.now function to know what the result will be
  test_with_mock "laps without name", Timex.Time, [now: fn -> {1, 0, 2} end] do
    w = Timer.start
    w = Timer.lap(w)
    w = Timer.lap(w)
    assert Watch.laps(w) === [{nil, {1, 0, 2}}, {nil, {1, 0, 2}}]
  end

  test "lap names" do
    w = Timer.start
    w = Timer.lap(w, "lap 1")
    w = Timer.lap(w, "lap 2")
    assert Watch.lap_names(w) === ["lap 1", "lap 2"]
  end
end
