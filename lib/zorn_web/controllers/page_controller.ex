defmodule ZornWeb.PageController do
  use ZornWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
