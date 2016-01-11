defmodule StopWatch.Timer do
  use Timex
  defstruct start: nil, laps: [], finish: nil

  def new(start \\ Time.now) do
    %StopWatch.Timer{start: start}
  end

  def lap(timer) do
    Map.update!(timer, :laps, &([Time.now | &1]))
  end

  def stop(timer) do
    Map.update!(timer, :finish, fn
      finish when is_nil(finish) -> Time.now
      _                          -> raise "The timer is already stopped"
    end)
  end

  def total_time(%StopWatch.Timer{start: start, finish: nil}) do
    Time.sub(Time.now, start)
  end
  def total_time(%StopWatch.Timer{start: start, finish: finish}) do
    Time.sub(finish, start)
  end
end
