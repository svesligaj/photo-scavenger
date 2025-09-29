defmodule PhotoScavengerWeb.Layouts do
  use PhotoScavengerWeb, :html

  attr :flash, :map, required: true
  def flash_group(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= for {type, msg} <- Enum.filter(@flash, fn {_, v} -> v end) do %>
        <div class={flash_class(type)} role="alert">
          <%= msg %>
        </div>
      <% end %>
    </div>
    """
  end

  defp flash_class(type) do
    base = "px-3 py-2 rounded"
    case type do
      :info -> base <> " bg-blue-100 text-blue-900"
      :error -> base <> " bg-red-100 text-red-900"
      _ -> base <> " bg-gray-100 text-gray-900"
    end
  end

  embed_templates "layouts/*"
end
