defmodule AddressTooling.Web.PageController do
  use AddressTooling.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
