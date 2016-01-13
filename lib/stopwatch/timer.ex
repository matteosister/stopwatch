defmodule Stopwatch.Timer do
  @moduledoc """
  This module provides a friendly API for working with timers

  It allows you to start, lap and stop Watch structs
  """

  use GenServer
  use Timex
  use Stopwatch

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: :timer_server])
  end

  @doc """
  Start a new timer by giving it an optional start time
  """
  @spec start(Timex.Time) :: Watch
  def start(start_time \\ Time.now) do
    GenServer.call(:timer_server, {:start, start_time})
  end

  @doc """
  Count the active timers

  ## Examples
      iex> use Stopwatch
      ...> Timer.count
      0

      iex> Timer.start("test")
      ...> Timer.count
      1

      iex> Timer.stop("test")
      ...> Timer.count
      0
  """
  @spec count :: integer
  def count do
    GenServer.call(:timer_server, :count)
  end

  @doc """
  a stopwatch has two buttons, one to start and stop it, and another to measure
  the **lap time**. This is what the lap method is for.

  You can optionally give the a name to the lap for later use
  """
  @spec lap(Stopwatch.Watch, binary) :: Stopwatch.Watch
  def lap(watch, name \\ nil) do
    GenServer.call(:timer_server, {:lap, watch, name})
  end

  @doc """
  Stop the given timer, and returns it.

  This will also remove it from the active timers.
  """
  @spec stop(Stopwatch.Watch) :: Stopwatch.Watch
  def stop(stopwatch) do
    GenServer.call(:timer_server, {:stop, stopwatch})
  end

  @doc """
  peek at the timer while it continues to measure. Useful for logging purposes.

  It returns a tuple with format {megasecs, secs, microsecs}
  """
  @spec peek(Stopwatch.Watch) :: {integer, integer, integer}
  def peek(stopwatch) do
    GenServer.call(:timer_server, {:peek, stopwatch})
  end

  @doc """
  clear all the active timers
  """
  @spec clear :: none
  def clear do
    GenServer.cast(:timer_server, :clear)
  end

  # GenServer callbacks
  def handle_call({:start, start_time}, _, stopwatches) do
    watch = Watch.new(start_time)
    {:reply, watch, [watch | stopwatches]}
  end

  def handle_call({:lap, watch, lap_name}, _, stopwatches) do
    {watch, new_list} = pop_stopwatch(stopwatches, watch)
    new_watch = Watch.lap(watch, lap_name)
    {:reply, new_watch, [new_watch | new_list]}
  end

  def handle_call({:stop, watch}, _, stopwatches) do
    {stopwatch, new_list} = pop_stopwatch(stopwatches, watch)
    {:reply, Watch.stop(stopwatch), new_list}
  end

  def handle_call({:peek, _}, _, []) do
    raise "There are no active stop watches"
  end
  def handle_call({:peek, watch}, _, stopwatches) do
    {:reply, Watch.total_time(get_stopwatch(stopwatches, watch)), stopwatches}
  end

  def handle_call(:count, _, stopwatches) do
    {:reply, length(stopwatches), stopwatches}
  end

  def handle_cast(:clear, _) do
    {:noreply, []}
  end

  defp pop_stopwatch(stopwatches, watch) do
    if exists?(stopwatches, watch) do
      {get_stopwatch(stopwatches, watch), delete_stopwatch(stopwatches, watch)}
    else
      {nil, stopwatches}
    end
  end

  defp get_stopwatch(stopwatches, watch) do
    Enum.find(stopwatches, &(&1 === watch))
  end

  defp delete_stopwatch(stopwatches, watch) do
    Enum.reject(stopwatches, &(&1 === watch))
  end

  defp exists?(stopwatches, watch) do
    get_stopwatch(stopwatches, watch) !== nil
  end
end
