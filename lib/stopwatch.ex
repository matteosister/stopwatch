defmodule Stopwatch do
  @moduledoc """
  Stopwatch is a library to measure elapsed time in your code.

  It is useful for logging purposes, for example to monitor some business
  critial portion of your apps or the response time of external services.

  ## Examples

  iex> Stopwatch.Timer.start(:test)
  ...> :timer.sleep(10)
  ...> t = Stopwatch.Timer.stop(:test)
  ...> Stopwatch.Watch.total_time(t) >= 10
  true
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
