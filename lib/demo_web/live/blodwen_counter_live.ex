defmodule DemoWeb.BlodwenCounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    Blodwen.render(assigns)
  end

  def mount(session, socket) do
    Blodwen.mount(session, socket)
  end

  def handle_event(event, unsigned_params, socket) do
    Blodwen.handle_event(event, unsigned_params, socket)
  end
end
