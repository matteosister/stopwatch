defmodule Stopwatch.Watch do
  use Timex
  use Stopwatch
  defstruct name: nil, start_time: nil, laps: [], finish_time: nil

  @doc """
  creates a new timer that starts from the given time
  defaults to now
  """
  def new(name, start_time \\ Time.now) do
    %Watch{name: name, start_time: start_time}
  end

  @doc """
  creates a lap in a timer
  """
  def lap(stopwatch, name) do
    Map.update!(stopwatch, :laps, &([{name, Time.now} | &1]))
  end

  @doc """
  stop a timer
  """
  def stop(stopwatch, at \\ Time.now)
  def stop(stopwatch = %Watch{finish_time: nil}, at) do
    Map.update!(stopwatch, :finish_time, fn(_) -> at end)
  end
  def stop(%Watch{name: name}, _) do
    raise "The stop watch #{name} is already stopped"
  end

  @doc """
  gets a timer total time
  """
  def total_time(%Watch{start_time: start_time, finish_time: nil}) do
    Time.sub(Time.now, start_time)
  end
  def total_time(%Watch{start_time: start_time, finish_time: finish_time}) do
    Time.sub(finish_time, start_time)
  end
end
