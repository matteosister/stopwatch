defmodule Stopwatch.Timer do
  use GenServer
  use Timex
  use Stopwatch

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: :timer_server])
  end

  # public api

  @doc """
  Start a new timer by giving it a an arbitrary name and an optional start time
  The name can be anything that is unique to your application. A good idea
  could be an atom or a binary string.

  Be careful, no error is raised if you start two timers with the same name,
  the last one will simply replace the first.
  """
  @spec start(any, Timex.Time) :: any
  def start(name, start_time \\ Time.now) do
    GenServer.call(:timer_server, {:start, name, start_time})
  end

  @doc """
  Count the active timers
  """
  def count do
    GenServer.call(:timer_server, :count)
  end

  @doc """
  stopwatches
  """
  def lap(stopwatch, name \\ nil) do
    GenServer.cast(:timer_server, {:lap, stopwatch, name})
  end

  def stop(stopwatch) do
    GenServer.call(:timer_server, {:stop, stopwatch})
  end

  def peek(stopwatch) do
    GenServer.call(:timer_server, {:peek, stopwatch})
  end

  def clear do
    GenServer.cast(:timer_server, :clear)
  end

  # GenServer callbacks
  def handle_call({:start, name, start_time}, _, stopwatches) do
    {_, stopwatches} = pop_stopwatch(stopwatches, name)
    stopwatch = Watch.new(name, start_time)
    {:reply, name, [stopwatch | stopwatches]}
  end

  def handle_call({:stop, name}, _, stopwatches) do
    {stopwatch, new_list} = pop_stopwatch(stopwatches, name)
    {:reply, stopwatch, new_list}
  end

  def handle_call({:peek, _}, _, []) do
    raise "There are no active stop watches"
  end
  def handle_call({:peek, name}, _, stopwatches) do
    {:reply, Watch.total_time(get_stopwatch(stopwatches, name)), stopwatches}
  end

  def handle_call(:count, _, stopwatches) do
    {:reply, length(stopwatches), stopwatches}
  end

  def handle_cast({:lap, name, lap_name}, stopwatches) do
    {stopwatch, new_list} = pop_stopwatch(stopwatches, name)
    {:noreply, [Watch.lap(stopwatch, lap_name) | new_list]}
  end

  def handle_cast(:clear, _) do
    {:noreply, []}
  end

  defp pop_stopwatch(stopwatches, name) do
    if exists?(stopwatches, name) do
      {get_stopwatch(stopwatches, name), delete_stopwatch(stopwatches, name)}
    else
      {nil, stopwatches}
    end
  end

  defp get_stopwatch(stopwatches, name) do
    Enum.find(stopwatches, name_checker(name))
  end

  defp delete_stopwatch(stopwatches, name) do
    Enum.reject(stopwatches, name_checker(name))
  end

  defp exists?(stopwatches, name) do
    get_stopwatch(stopwatches, name) !== nil
  end

  defp name_checker(name) do
    &(&1.name === name)
  end
end
