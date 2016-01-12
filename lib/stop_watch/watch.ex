defmodule StopWatch.Watch do
  use Timex
  use StopWatch
  defstruct name: nil, start_time: nil, laps: [], finish: nil

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
  def stop(stop_watch) do
    Map.update!(stop_watch, :finish, fn
      finish when is_nil(finish) ->
        Time.now
      _                          ->
        raise "The timer #{stop_watch.name} is already stopped"
    end)
  end

  @doc """
  gets a timer total time
  """
  def total_time(%Watch{start_time: start_time, finish: nil}) do
    Time.sub(Time.now, start_time)
  end
  def total_time(%Watch{start_time: start_time, finish: finish}) do
    Time.sub(finish, start_time)
  end
end
