defmodule StopWatch.Watch do
  use Timex
  use StopWatch
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
  def lap(stop_watch, name) do
    Map.update!(stop_watch, :laps, &([{name, Time.now} | &1]))
  end

  @doc """
  stop a timer
  """
  def stop(stop_watch, at \\ Time.now)
  def stop(stop_watch = %Watch{finish_time: nil}, at) do
    Map.update!(stop_watch, :finish_time, fn(_) -> at end)
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
