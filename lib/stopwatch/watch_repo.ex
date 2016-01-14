defmodule Stopwatch.WatchRepo do
  @moduledoc """
  This module provides a friendly API to start, stop and lap a watch struct

  It allows you to start, lap and stop

  internally it is a GenServer implementation that wraps around the list of
  active timers.
  """
  use GenServer
  use Timex

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], [name: :watch_repo])
  end

  @doc """
  Store a watch for later use
  """
  @spec store(Stopwatch.Watch, any) :: any
  def store(watch, watch_name) do
    GenServer.call(:watch_repo, {:store, watch, watch_name})
  end

  @doc """
  Count the active timers

  ## Examples
      iex> Stopwatch.Timer.count
      0

      iex> Stopwatch.Timer.start("test")
      ...> Timer.count
      1

      iex> Stopwatch.Timer.stop("test")
      ...> Timer.count
      0
  """
  @spec count :: integer
  def count do
    GenServer.call(:watch_repo, :count)
  end

  @doc """
  a stopwatch has two buttons, one to start and stop it, and another to measure
  the **lap time**. This is what the lap method is for.

  You can optionally give the a name to the lap for later use
  """
  @spec lap(any, binary, Timex.Time) :: none
  def lap(watch_name, lap_name \\ nil, at \\ Time.now) do
    GenServer.cast(:watch_repo, {:lap, watch_name, lap_name, at})
  end

  @doc """
  peek at the timer while it continues to measure. Useful for logging purposes.

  It returns a tuple with format {megasecs, secs, microsecs}
  """
  @spec peek(any) :: {integer, integer, integer}
  def peek(watch_name) do
    GenServer.call(:watch_repo, {:peek, watch_name})
  end

  @doc """
  Stop the given timer, and returns it.

  This will also remove it from the active timers.
  """
  @spec stop(Stopwatch.Watch) :: Stopwatch.Watch
  def stop(watch_name, at \\ Time.now) do
    GenServer.call(:watch_repo, {:stop, watch_name, at})
  end

  @doc """
  clear all the active timers
  """
  @spec clear_all :: none
  def clear_all do
    GenServer.cast(:watch_repo, :clear_all)
  end

  # GenServer callbacks
  def handle_call({:store, watch, watch_name}, _, watches) do
    {:reply, watch_name, [{watch_name, watch} | watches]}
  end

  def handle_call({:stop, watch_name, at}, _, watches) do
    {{name, watch}, other_watches} = pop_stopwatch(watches, watch_name)
    {:reply, Stopwatch.Watch.stop(watch, at), other_watches}
  end

  def handle_call({:peek, _}, _, []) do
    raise "There are no active stop watches"
  end
  def handle_call({:peek, watch_name}, _, watches) do
    {name, watch} = get_stopwatch(watches, watch_name)
    {:reply, Stopwatch.Watch.total_time(watch), watches}
  end

  def handle_call(:count, _, watches) do
    {:reply, length(watches), watches}
  end

  def handle_cast({:lap, watch_name, lap_name, at}, watches) do
    {{name, watch}, other_watches} = pop_stopwatch(watches, watch_name)
    {:noreply, [{name, Stopwatch.Watch.lap(watch, lap_name, at)} | other_watches]}
  end

  def handle_cast(:clear_all, _) do
    {:noreply, []}
  end

  defp pop_stopwatch(watches, watch_name) do
    if exists?(watches, watch_name) do
      {get_stopwatch(watches, watch_name), delete_stopwatch(watches, watch_name)}
    else
      {nil, watches}
    end
  end

  defp get_stopwatch(watches, watch_name) do
    Enum.find(watches, fn {name, _} -> watch_name === name end)
  end

  defp delete_stopwatch(watches, watch_name) do
    Enum.reject(watches, fn {name, _} -> watch_name === name end)
  end

  defp exists?(watches, watch_name) do
    get_stopwatch(watches, watch_name) !== nil
  end
end
