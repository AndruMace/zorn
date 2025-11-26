defmodule ZornWeb.UsersSessionControllerTest do
  use ZornWeb.ConnCase, async: true

  import Zorn.AccountsFixtures
  alias Zorn.Accounts

  setup do
    %{unconfirmed_users: unconfirmed_users_fixture(), users: users_fixture()}
  end

  describe "POST /user/log-in - email and password" do
    test "logs the users in", %{conn: conn, users: users} do
      users = set_password(users)

      conn =
        post(conn, ~p"/user/log-in", %{
          "users" => %{"email" => users.email, "password" => valid_users_password()}
        })

      assert get_session(conn, :users_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ users.email
      assert response =~ ~p"/user/settings"
      assert response =~ ~p"/user/log-out"
    end

    test "logs the users in with remember me", %{conn: conn, users: users} do
      users = set_password(users)

      conn =
        post(conn, ~p"/user/log-in", %{
          "users" => %{
            "email" => users.email,
            "password" => valid_users_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_zorn_web_users_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the users in with return to", %{conn: conn, users: users} do
      users = set_password(users)

      conn =
        conn
        |> init_test_session(users_return_to: "/foo/bar")
        |> post(~p"/user/log-in", %{
          "users" => %{
            "email" => users.email,
            "password" => valid_users_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "redirects to login page with invalid credentials", %{conn: conn, users: users} do
      conn =
        post(conn, ~p"/user/log-in?mode=password", %{
          "users" => %{"email" => users.email, "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/user/log-in"
    end
  end

  describe "POST /user/log-in - magic link" do
    test "logs the users in", %{conn: conn, users: users} do
      {token, _hashed_token} = generate_users_magic_link_token(users)

      conn =
        post(conn, ~p"/user/log-in", %{
          "users" => %{"token" => token}
        })

      assert get_session(conn, :users_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ users.email
      assert response =~ ~p"/user/settings"
      assert response =~ ~p"/user/log-out"
    end

    test "confirms unconfirmed users", %{conn: conn, unconfirmed_users: users} do
      {token, _hashed_token} = generate_users_magic_link_token(users)
      refute users.confirmed_at

      conn =
        post(conn, ~p"/user/log-in", %{
          "users" => %{"token" => token},
          "_action" => "confirmed"
        })

      assert get_session(conn, :users_token)
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Users confirmed successfully."

      assert Accounts.get_users!(users.id).confirmed_at

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ users.email
      assert response =~ ~p"/user/settings"
      assert response =~ ~p"/user/log-out"
    end

    test "redirects to login page when magic link is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/user/log-in", %{
          "users" => %{"token" => "invalid"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "The link is invalid or it has expired."

      assert redirected_to(conn) == ~p"/user/log-in"
    end
  end

  describe "DELETE /user/log-out" do
    test "logs the users out", %{conn: conn, users: users} do
      conn = conn |> log_in_users(users) |> delete(~p"/user/log-out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :users_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the users is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/user/log-out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :users_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
