defmodule Stopwatch do
  @moduledoc false
  use Application

  defmacro __using__(_) do
    quote do
      alias Stopwatch.Watch
    end
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stopwatch.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
