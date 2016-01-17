defmodule Stopwatch.Watch do
  @moduledoc """
  Methods for working with a Watch struct, after the Timer.stop method is called
  """
  use Timex
  use Stopwatch
  defstruct start_time: nil, laps: [], finish_time: nil

  @doc """
  creates a Watch struct
  """
  def new(start_time \\ Time.now) do
    %Watch{start_time: start_time}
  end

  @doc """
  creates a new lap
  """
  def lap(watch, name, at) do
    Map.update!(watch, :laps, &([{name, at} | &1]))
  end

  def lap_stop(watch, name, at \\ Time.now) do
    watch
    |> lap(name, at)
    |> stop(at)
  end

  @doc """
  stop the watch
  """
  def stop(watch, at \\ Time.now)
  def stop(watch = %Watch{finish_time: nil}, at) do
    watch
    |> Map.update!(:finish_time, fn(_) -> at end)
    |> add_stop_lap(at)
  end
  def stop(watch, _), do: watch

  defp add_stop_lap(watch = %Watch{finish_time: finish_time}, at) do
    case last_lap_finish_time(watch) === at do
      true  -> watch
      false -> lap(watch, :stop, at)
    end
  end

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
