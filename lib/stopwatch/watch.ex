defmodule Stopwatch.Watch do
  use Timex
  use Stopwatch
  defstruct start_time: nil, laps: [], finish_time: nil

  @doc false
  def new(start_time \\ Time.now) do
    %Watch{start_time: start_time}
  end

  @doc false
  def lap(watch, name) do
    Map.update!(watch, :laps, &([{name, Time.now} | &1]))
  end

  @doc false
  def stop(watch, at \\ Time.now)
  def stop(watch = %Watch{finish_time: nil}, at) do
    Map.update!(watch, :finish_time, fn(_) -> at end)
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
    Time.sub(Time.now, start) |> convert_time(unit) |> round
  end
  def total_time(%Watch{start_time: start, finish_time: finish}, unit) do
    Time.sub(finish, start) |> convert_time(unit) |> round
  end

  defp convert_time(time, unit) do
    method = "to_#{to_string(unit)}"
    apply(Timex.Time, String.to_atom(method), [time])
  end

  @doc """
  extract lap names from a watch
  """
  @spec lap_names(Stopwatch.Watch) :: [binary]
  def lap_names(%Watch{laps: []}), do: []
  def lap_names(%Watch{laps: laps}) do
    laps
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.reverse
  end

  @doc """
  extract laps from a watch

  the output is a list of tuples with {name, time}
  """
  @spec laps(Stopwatch.Watch) :: [{binary, {integer, integer, integer}}]
  def laps(%Watch{laps: []}), do: []
  def laps(%Watch{laps: laps}), do: Enum.reverse(laps)
end
