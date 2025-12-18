defmodule HeadsUpWeb.EffortLive.Index do
  use HeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, 2000)
    end

    {:ok,
     assign(
       socket,
       responders: 0,
       minutes_per_responder: 10,
       quantity: 3,
       page_title: "Effort"
     )}
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    {:noreply, update(socket, :responders, &(&1 + String.to_integer(quantity)))}
  end

  def handle_event("set-quantity", %{"quantity" => quantity}, socket) do
    {:noreply, assign(socket, quantity: String.to_integer(quantity))}
  end

  def handle_event("set-mpr", %{"minutes_per_responder" => mpr}, socket) do
    {:noreply, assign(socket, minutes_per_responder: String.to_integer(mpr))}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 2000)

    {:noreply, update(socket, :responders, &(&1 + 3))}
  end
end
