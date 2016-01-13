defmodule Stopwatch.Watch do
  use Timex
  use Stopwatch
  defstruct start_time: nil, laps: [], finish_time: nil

  @doc false
  def new(start_time \\ Time.now) do
    %Watch{start_time: start_time}
  end

  @doc false
  def lap(watch, name, at \\ Time.now) do
    Map.update!(watch, :laps, &([{name, at} | &1]))
  end

  @doc false
  def stop(watch, at \\ Time.now)
  def stop(watch = %Watch{finish_time: nil}, at) do
    watch
    |> Map.update!(:finish_time, fn(_) -> at end)
    |> lap(:stop, at)
  end
  def stop(watch, _), do: watch

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
    calculate_diff(start, Time.now)
  end
  def total_time(%Watch{start_time: start, finish_time: finish}, unit) do
    calculate_diff(start, finish)
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
  def laps(watch = %Watch{laps: []}, unit) do
    [{:total_time, total_time(watch, unit)}]
  end
  def laps(watch = %Watch{start_time: start, finish_time: finish, laps: laps}, unit) do
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
