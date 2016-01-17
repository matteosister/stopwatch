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
    assert is_float(Watch.total_time(watch))
  end

  test "total time with finished timer" do
    watch = Watch.new(Time.zero) |> Watch.stop({0, 1, 1})
    assert 1_000.001 === Watch.total_time(watch)
  end

  # I need to mock the Time.now function to know what the result will be
  test "laps" do
    start = {1452, 727938, 544038}
    time1 = {1452, 727938, 544438}
    time2 = {1452, 727938, 544638}
    stop  = {1452, 727938, 545038}
    w = Watch.new(start)
    w = Watch.lap(w, "lap 1", time1)
    w = Watch.lap(w, "lap 2", time2)
    w = Watch.stop(w, stop)
    assert Watch.laps(w) === [{"lap 1", 0.4}, {"lap 2", 0.2}, {:stop, 0.4}, {:total_time, 1.0}]
  end

  test "last_lap method" do
    start = {1452, 727938, 544038}
    stop  = {1452, 727938, 544438}
    w = Watch.new(start)
    w = Watch.last_lap(w, "the_only_lap", stop)
    assert Watch.laps(w) === [{"the_only_lap", 0.4}, {:total_time, 0.4}]
  end

  # I need to mock the Time.now function to know what the result will be
  # test_with_mock "laps without name", Timex.Time, [now: fn -> {1, 0, 2} end] do
  #   w = Timer.start
  #   w = Timer.lap(w)
  #   w = Timer.lap(w)
  #   assert Watch.laps(w) === [{nil, {1, 0, 2}}, {nil, {1, 0, 2}}]
  # end

  test "empty list for timer without laps" do
    w = Watch.new
    assert Watch.laps(w) === []
  end
end
