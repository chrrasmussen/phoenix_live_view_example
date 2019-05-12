defmodule DemoWeb.BlodwenCounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    Blodwen.render(assigns)
  end

  def mount(_session, socket) do
    Blodwen.mount(socket)
  end

  def handle_event(event, _, socket) do
    Blodwen.handle_event(event, socket)
  end
end
