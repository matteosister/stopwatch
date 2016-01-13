defmodule Stopwatch do
  @moduledoc """
  Stopwatch is a library to measure elapsed time in your code.

  It is useful for logging purposes, for example to monitor some business
  critial portion of your apps or the response time of external services.

  ## Examples

      use Stopwatch
      timer = Timer.start
      query_db()
      timer = Timer.lap(timer, "query db")
      export_to_csv()
      final_timer = Timer.stop(timer)

      IO.puts(Watch.total_time(final_timer)) # 15808.752 defaults to microsecs
      IO.puts(Watch.total_time(final_timer, :secs)) # 15.808752
      IO.puts(Watch.total_time(final_timer, :usecs)) # 15808752

      IO.puts(Watch.laps())
  """
  use Application

  defmacro __using__(_) do
    quote do
      alias Stopwatch.Watch
      alias Stopwatch.Timer
    end
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Stopwatch.Timer, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stopwatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
