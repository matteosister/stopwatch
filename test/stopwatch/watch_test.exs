defmodule Stopwatch.WatchTest do
  use ExUnit.Case, async: false
  doctest Stopwatch.Watch
  use Stopwatch
  use Timex

  test "new timer" do
    time = Time.zero
    assert %Watch{start_time: time} === Watch.new(time)
  end

  test "total time with unfinished timer" do
    watch = Watch.new(Time.zero)
    assert is_float(Watch.get_total_time(watch))
  end

  test "total time with finished timer" do
    watch = Watch.new(Time.zero) |> Watch.stop({0, 1, 1})
    assert 1_000.001 === Watch.get_total_time(watch)
  end

  # I need to mock the Time.now function to know what the result will be
  test "method get_laps" do
    start = {1452, 727938, 544038}
    time1 = {1452, 727938, 544438}
    time2 = {1452, 727938, 544638}
    stop  = {1452, 727938, 545038}
    w = Watch.new(start)
    w = Watch.lap(w, "lap 1", time1)
    w = Watch.lap(w, "lap 2", time2)
    w = Watch.stop(w, stop)
    assert Watch.get_laps(w) === [{"lap 1", 0.4}, {"lap 2", 0.2}, {:stop, 0.4}]
  end

  # test "get_lap_time" do
  #   start = {1452, 727938, 544038}
  #   time1 = {1452, 727938, 544438}
  #   stop  = {1452, 727938, 545038}
  #   w = Watch.new(start)
  #   w = Watch.lap(w, "lap 1", time1)
  #   w = Watch.stop(w, stop)
  #   assert get_lap_time(w, "lap 1") === 0.4
  # end

  test "last_lap method" do
    start = {1452, 727938, 544038}
    stop  = {1452, 727938, 544438}
    w = Watch.new(start) |> Watch.last_lap("the_only_lap", stop)
    assert Watch.get_laps(w) === [{"the_only_lap", 0.4}]
  end

  test "empty list for timer without laps" do
    w = Watch.new
    assert Watch.get_laps(w) === []
  end

  test "stop! throws exceptions" do
    w = Watch.new
    w = Watch.stop!(w)
    assert_raise ArgumentError, "you cannot stop an already stopped watch", fn ->
      Watch.stop!(w)
    end
  end
end
