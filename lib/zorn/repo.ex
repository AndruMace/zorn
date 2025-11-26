defmodule Zorn.Repo do
  use Ecto.Repo,
    otp_app: :zorn,
    adapter: Ecto.Adapters.Postgres
end
