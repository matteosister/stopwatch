defmodule Stopwatch.Watch do
  use Timex
  use Stopwatch
  defstruct name: nil, start_time: nil, laps: [], finish_time: nil

  @doc false
  def new(name, start_time \\ Time.now) do
    %Watch{name: name, start_time: start_time}
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
end
