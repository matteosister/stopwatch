defmodule Stopwatch.Watch do
  @moduledoc """
  Methods for creating, working and accessing a Watch struct
  """
  use Timex
  use Stopwatch
  defstruct start_time: nil, laps: [], finish_time: nil

  @doc """
  create a Watch struct with a unique name
  """
  @spec store(binary | atom, Time) :: Stopwatch.Watch
  def store(name, start_time \\ Time.now) do
    watch = new(start_time)
    WatchRepo.store(watch, name)
  end

  @doc """
  create a Watch struct
  """
  @spec new(Time) :: Stopwatch.Watch
  def new(start_time \\ Time.now) do
    %Watch{start_time: start_time}
  end

  @doc """
  create a new lap
  """
  @spec lap(Stopwatch.Watch | binary | atom, binary | atom, Time) :: Stopwatch.Watch
  def lap(watch, name, at) when is_binary(watch) or is_atom(watch) do
    watch
    |> WatchRepo.pop
    |> lap(name, at)
    |> WatchRepo.store(watch)
  end
  def lap(watch = %Watch{laps: laps}, name, at) do
    %{watch | laps: [{name, at} | laps]}
  end

  @doc """
  create a new lap and stop the timer
  """
  @spec last_lap(Stopwatch.Watch | binary | atom, binary | atom, Time) :: Stopwatch.Watch
  def last_lap(watch, name, at \\ Time.now)
  def last_lap(watch, name, at) when is_binary(watch) or is_atom(watch) do
    watch
    |> WatchRepo.pop
    |> last_lap(name, at)
    |> WatchRepo.store(watch)
  end
  def last_lap(watch, name, at) when is_binary(name) do
    watch
    |> lap(name, at)
    |> stop(at)
  end

  @doc """
  stop the watch
  """
  @spec stop(Stopwatch.Watch | binary | atom, Time) :: Stopwatch.Watch
  def stop(watch, at \\ Time.now)
  def stop(watch, at) when is_binary(watch) or is_atom(watch) do
    watch
    |> WatchRepo.pop
    |> stop(at)
  end
  def stop(watch = %Watch{finish_time: nil}, at) do
    %{watch | finish_time: at }
    |> add_stop_lap(at)
  end
  def stop(watch, _), do: watch

  defp add_stop_lap(watch, at) when is_binary(watch) or is_atom(watch) do
    watch
    |> WatchRepo.pop
    |> add_stop_lap(at)
    |> WatchRepo.store(watch)
  end
  defp add_stop_lap(watch, at) do
    case last_lap_finish_time(watch) === at do
      true  -> watch
      false -> lap(watch, :stop, at)
    end
  end

  @doc """
  return the last lap finish time. If the watch do not have any laps returns nil

  ## Examples

      iex> use Stopwatch
      iex> w = Watch.new |> Watch.last_lap_finish_time
      nil

      iex> use Stopwatch
      ...> w = Watch.new({1452, 727938, 544038}) |> Watch.last_lap("all done", {1452, 727938, 544438})
      ...> Watch.last_lap_finish_time(w)
      {1452, 727938, 544438}
  """
  @spec last_lap_finish_time(Stopwatch.Watch | binary | atom) :: {integer, integer, integer}
  def last_lap_finish_time(%Watch{laps: []}), do: nil
  def last_lap_finish_time(%Watch{laps: [last_lap | _]}) do
    elem(last_lap, 1)
  end

  @doc """
  gets a timer total time

  possible units are:
  - :usecs
  - :msecs
  - :secs
  - :mins
  - :hours
  - :days
  - :weeks
  """
  @spec total_time(Stopwatch.Watch, atom) :: float | integer
  def total_time(watch, unit \\ :msecs)
  def total_time(%Watch{start_time: start, finish_time: nil}, unit) do
    calculate_diff(start, Time.now, unit)
  end
  def total_time(%Watch{start_time: start, finish_time: finish}, unit) do
    calculate_diff(start, finish, unit)
  end

  defp calculate_diff(from, to, unit \\ :msecs) do
    Time.sub(to, from)
    |> convert_time(unit)
  end

  defp convert_time(time, unit) do
    method = "to_#{to_string(unit)}"
    apply(Timex.Time, String.to_atom(method), [time])
  end

  @doc """
  extract laps from a watch

  the output is a list of tuples with {name, time}
  """
  @spec laps(Stopwatch.Watch) :: [{binary, {integer, integer, integer}}]
  def laps(watch, unit \\ :msecs)
  def laps(%Watch{laps: []}, _) do
    []
  end
  def laps(watch = %Watch{start_time: start, laps: laps}, unit) do
    lap_times = laps
    |> Enum.reverse
    |> Enum.reduce([], lap_reducer(start))
    |> Enum.map(fn({name, {from, to}}) -> {name, calculate_diff(from, to)} end)

    lap_times ++ [{:total_time, total_time(watch, unit)}]
  end

  defp lap_reducer(start) do
    fn
      {name, finish}, [] ->
        [{name, {start, finish}}]
      {name, finish}, previous_laps ->
        last_lap_finish = previous_laps
        |> List.last
        |> elem(1)
        |> elem(1)
        previous_laps ++ [{name, {last_lap_finish, finish}}]
    end
  end
end
