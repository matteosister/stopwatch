defmodule StopWatch.Timer do
  use GenServer
  use Timex
  use StopWatch

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: :timer_server])
  end

  # public api
  def start(name, start_time \\ Time.now) do
    GenServer.call(:timer_server, {:start, name, start_time})
  end

  def lap(stop_watch, name \\ nil) do
    GenServer.cast(:timer_server, {:lap, stop_watch, name})
  end

  def stop(stop_watch) do
    GenServer.call(:timer_server, {:stop, stop_watch})
  end

  def peek(stop_watch) do
    GenServer.call(:timer_server, {:peek, stop_watch})
  end

  def count do
    GenServer.call(:timer_server, :count)
  end

  # GenServer callbacks
  def handle_call({:start, name, start_time}, _, stop_watches) do
    stop_watches = if exists?(stop_watches, name) do
      {_, new_list} = pop_stopwatch(stop_watches, name)
      new_list
    else
      stop_watches
    end
    stop_watch = Watch.new(name, start_time)
    {:reply, name, [stop_watch | stop_watches]}
  end

  def handle_call({:stop, name}, _, stop_watches) do
    {stop_watch, new_list} = pop_stopwatch(stop_watches, name)
    {:reply, stop_watch, new_list}
  end

  def handle_call({:peek, _}, _, []) do
    raise "There are no active stop watches"
  end
  def handle_call({:peek, name}, _, stop_watches) do
    {:reply, Watch.total_time(get_stopwatch(stop_watches, name)), stop_watches}
  end

  def handle_call(:count, _, stop_watches) do
    {:reply, length(stop_watches), stop_watches}
  end

  def handle_cast({:lap, name, lap_name}, stop_watches) do
    {stop_watch, new_list} = pop_stopwatch(stop_watches, name)
    {:noreply, [Watch.lap(stop_watch, lap_name) | new_list]}
  end

  defp pop_stopwatch(stop_watches, name) do
    unless exists?(stop_watches, name) do
      raise "stopwatch named \"#{name}\" doesn't exists"
    end
    {get_stopwatch(stop_watches, name), delete_stopwatch(stop_watches, name)}
  end

  defp get_stopwatch(stop_watches, name) do
    Enum.find(stop_watches, name_checker(name))
  end

  defp delete_stopwatch(stop_watches, name) do
    Enum.reject(stop_watches, name_checker(name))
  end

  defp exists?(stop_watches, name) do
    get_stopwatch(stop_watches, name) !== nil
  end

  defp names(stop_watches) do
    Enum.map(stop_watches, &(&1.name))
  end

  defp name_checker(name) do
    &(&1.name === name)
  end
end
