defmodule Stopwatch do
  @moduledoc false
  
  defmacro __using__(_) do
    quote do
      alias Stopwatch.Watch
    end
  end
end
