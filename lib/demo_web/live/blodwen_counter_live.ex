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

  def handle_event("inc", _, socket) do
    Blodwen.inc(socket)
  end

  def handle_event("dec", _, socket) do
    Blodwen.dec(socket)
  end
end
