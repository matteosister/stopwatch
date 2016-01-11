defmodule StopWatch.TimerServer do
  use GenServer
  use Timex
  alias StopWatch.Timer

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: :timer_server])
  end

  # public api
  def start do
    GenServer.call(:timer_server, :start)
  end

  def stop(timer) do
    GenServer.call(:timer_server, {:stop, timer})
  end

  def peek(timer) do
    GenServer.call(:timer_server, {:peek, timer})
  end

  def count do
    GenServer.call(:timer_server, :count)
  end

  # GenServer callbacks
  def handle_call(:start, _, timers) do
    timer = Timer.new
    {:reply, timer, [timer | timers]}
  end

  def handle_call({:stop, timer}, _, timers) do
    {:reply, Timer.total_time(timer), List.delete(timers, timer)}
  end

  def handle_call({:peek, _}, _, []), do: raise "There are no active timers"
  def handle_call({:peek, timer}, _, timers) do
    unless Enum.member?(timers, timer) do
      raise "Timer not found"
    end
    {:reply, Timer.total_time(timer), timers}
  end

  def handle_call(:count, _, timers) do
    {:reply, length(timers), timers}
  end
end
