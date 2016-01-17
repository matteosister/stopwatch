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
  @spec store(Stopwatch.Watch, binary | atom) :: Stopwatch.Watch
  def store(watch, watch_name) do
    GenServer.call(:watch_repo, {:store, watch, watch_name})
  end

  @doc """
  Store a watch for later use
  """
  @spec pop(binary | atom) :: Stopwatch.Watch
  def pop(watch_name) do
    GenServer.call(:watch_repo, {:pop, watch_name})
  end

  @doc """
  get the number of active timers
  """
  @spec count :: integer
  def count do
    GenServer.call(:watch_repo, :count)
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

  def handle_call({:pop, watch_name}, _, watches) do
    {{_, watch}, other_watches} = pop_stopwatch(watches, watch_name)
    {:reply, watch, other_watches}
  end

  def handle_call(:count, _, watches) do
    {:reply, length(watches), watches}
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
