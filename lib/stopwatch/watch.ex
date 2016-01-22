defmodule Stopwatch.Watch do
  @moduledoc """
  Methods for creating, working and accessing a Watch struct

  All methods that starts with a **get_*** reads the watch status, while the others manipulate it.

  For every method that accepts a unit parameter refer to the [timex library docs](https://hexdocs.pm/timex/extra-working-with-time.html)
  """
  use Timex
  use Stopwatch

  defstruct start_time: nil, laps: [], finish_time: nil

  @doc """
  create a new Watch
  """
  @spec new(Time) :: Stopwatch.Watch
  def new(start_time \\ Time.now) do
    %Watch{start_time: start_time}
  end

  @doc """
  create a lap by givint it a name and an optional end time
  """
  @spec lap(Stopwatch.Watch, any, Time) :: Stopwatch.Watch
  def lap(watch = %Watch{laps: laps}, name, at \\ Time.now) do
    %{watch | laps: [{name, {last_lap_finish_time(watch), at}} | laps]}
  end

  @doc """
  create the last lap by giving it a name, and then stop the watch
  """
  @spec last_lap(Stopwatch.Watch, any, Time) :: Stopwatch.Watch
  def last_lap(watch, name, at \\ Time.now)
  def last_lap(watch, name, at) do
    watch
    |> lap(name, at)
    |> stop(at)
  end

  @doc """
  stop the watch, if the watch has already been stopped don't do nothing
  """
  @spec stop(Stopwatch.Watch, Time) :: Stopwatch.Watch
  def stop(watch, at \\ Time.now)
  def stop(watch = %Watch{finish_time: nil}, at) do
    %{watch | finish_time: at }
    |> add_stop_lap(at)
  end
  def stop(watch, _), do: watch

  @doc """
  stop the watch and throws and exception if the watch is already stopped
  """
  @spec stop!(Stopwatch.Watch, Time) :: Stopwatch.Watch
  def stop!(watch, at \\ Time.now)
  def stop!(watch = %Watch{finish_time: finish_time}, at) do
    case finish_time do
      nil -> watch |> stop(at)
      _   -> raise ArgumentError, "you cannot stop an already stopped watch"
    end
  end

  defp add_stop_lap(watch, at) do
    case last_lap_finish_time(watch) === at do
      true  -> watch
      false -> lap(watch, :stop, at)
    end
  end

  @doc """
  gets a timer total time
  """
  @spec get_total_time(Stopwatch.Watch, atom) :: float | integer
  def get_total_time(watch, unit \\ :msecs)
  def get_total_time(%Watch{start_time: start, finish_time: nil}, unit) do
    calculate_diff(start, Time.now, unit)
  end
  def get_total_time(%Watch{start_time: start, finish_time: finish}, unit) do
    calculate_diff(start, finish, unit)
  end

  @doc """
  extract all laps from a watch

  the output is a list of tuples with {name, {start_time, finish_time}}
  """
  @spec get_laps(Stopwatch.Watch, atom) :: [{binary, {integer, integer, integer}}]
  def get_laps(watch, unit \\ :msecs)
  def get_laps(%Watch{laps: []}, _), do: []
  def get_laps(%Watch{laps: laps}, unit) do
    laps
    |> Enum.map(fn({name, {from, to}}) -> {name, calculate_diff(from, to, unit)} end)
    |> Enum.reverse
  end

  @doc """
  extract lap names from a watch

  ## Examples
      iex> Stopwatch.Watch.new |> Stopwatch.Watch.lap(:test) |> Stopwatch.Watch.lap(:test2) |> Stopwatch.Watch.get_lap_names
      [:test, :test2]

      iex> Stopwatch.Watch.new |> Stopwatch.Watch.get_lap_names
      []
  """
  @spec get_lap_names(Stopwatch.Watch) :: [binary]
  def get_lap_names(%Watch{laps: []}), do: []
  def get_lap_names(watch) do
    Enum.map(get_laps(watch), &lap_name/1)
  end

  @doc """
  get a single lap time by its name, if the name do not exists returns nil

  ## Examples
      iex> use Stopwatch
      ...> watch = Watch.new({0, 0, 100_000}) |> Watch.last_lap(:test, {0, 0, 200000})
      ...> Watch.get_lap_time(watch, :not_existent)
      nil

      iex> use Stopwatch
      ...> watch = Watch.new({0, 0, 100_000}) |> Watch.lap(:first, {0, 0, 150_000}) |> Watch.last_lap(:test, {0, 0, 200_000})
      ...> Watch.get_lap_time(watch, :test, :secs)
      0.05
  """
  @spec get_lap_time(Stopwatch.Watch, any, atom) :: number | nil
  def get_lap_time(watch, name, unit \\ :msecs)
  def get_lap_time(%Watch{laps: []}, _, _), do: nil
  def get_lap_time(%Watch{laps: laps}, name, unit) do
    case Enum.find(laps, nil, lap_matcher(name)) do
      nil             -> nil
      {_, {from, to}} -> calculate_diff(from, to, unit)
    end
  end

  @doc """
  get a single lap time by its name, if the name do not exists raises an exception

  ## Examples
      iex> Stopwatch.Watch.new |> Stopwatch.Watch.last_lap(:test) |> Stopwatch.Watch.get_lap_time!(:not_existent)
      ** (ArgumentError) the lap named not_existent was not found
  """
  @spec get_lap_time!(Stopwatch.Watch, any, atom) :: number
  def get_lap_time!(%Watch{laps: laps}, name, unit \\ :msecs) do
    case Enum.find(laps, nil, lap_matcher(name)) do
      nil             -> raise ArgumentError, "the lap named #{name} was not found"
      {_, {from, to}} -> calculate_diff(from, to, unit)
    end
  end

  defp calculate_diff(from, to, unit) do
    Time.sub(to, from)
    |> convert_time(unit)
  end

  defp convert_time(time, unit) do
    method = "to_#{to_string(unit)}"
    apply(Timex.Time, String.to_atom(method), [time])
  end

  defp last_lap_finish_time(%Watch{start_time: start_time, laps: []}), do: start_time
  defp last_lap_finish_time(%Watch{laps: [last_lap | _]}) do
    {_, {_, finish_time}} = last_lap
    finish_time
  end

  defp lap_matcher(name) do
    fn
      {^name, _} -> true
      _          -> false
    end
  end

  defp lap_name({name, _}), do: name
end
