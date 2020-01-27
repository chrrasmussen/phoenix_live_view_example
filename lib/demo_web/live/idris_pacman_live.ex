defmodule DemoWeb.IdrisPacManLive do
  @idris_module :"Idris.PacMan"

  defdelegate __live__(), to: @idris_module
  defdelegate mount(session, socket), to: @idris_module
  defdelegate handle_event(event, params, socket), to: @idris_module
  defdelegate handle_info(params, socket), to: @idris_module
  defdelegate render(assigns), to: @idris_module
end
