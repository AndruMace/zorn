defmodule ZornWeb.UsersLive.RegistrationTest do
  use ZornWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Zorn.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/user/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_users(users_fixture())
        |> live(~p"/user/register")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/user/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(users: %{"email" => "with spaces"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
    end
  end

  describe "register users" do
    test "creates account but does not log in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/user/register")

      email = unique_users_email()
      attrs =
        valid_users_attributes(%{
          email: email,
          password: valid_users_password(),
          password_confirmation: valid_users_password()
        })

      # Submit form with explicit password params since password fields don't show values
      users_params = %{
        "email" => attrs.email,
        "username" => attrs.username,
        "password" => attrs.password,
        "password_confirmation" => attrs.password_confirmation
      }

      assert {:ok, conn} =
        lv
        |> form("#registration_form", users: attrs)
        |> render_submit(%{"users" => users_params})
        |> follow_redirect(conn, ~p"/user/log-in")

      html = html_response(conn, 200)

      assert html =~
               ~r/An email was sent to .*, please access it to confirm your account/
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/user/register")

      users = users_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          users: %{"email" => users.email}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/user/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("main a", "Log in")
        |> render_click()
        |> follow_redirect(conn, ~p"/user/log-in")

      assert login_html =~ "Log in"
    end
  end
end
