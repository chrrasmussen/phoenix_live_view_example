defmodule DemoWeb.BlodwenCounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1 phx-click="boom">The count is: <%= @val %></h1>
      <button phx-click="boom" class="alert-danger">BOOM</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    """
  end

  def mount(_session, socket) do
    Blodwen.mount(socket)
  end

  def handle_event(event, _, socket) do
    Blodwen.handle_event(event, socket)
  end
end
