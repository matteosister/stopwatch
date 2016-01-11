defmodule StopWatch do
  use Application

  defmacro __using__(_) do
    quote do
      alias StopWatch.Timer
    end
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(StopWatch.TimerServer, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StopWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
