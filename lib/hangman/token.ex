defmodule Hangman.Token do

  @spec auth_sign(map()) :: binary()
  def auth_sign(data) do
    Phoenix.Token.sign(HangmanWeb.Endpoint, "auth", data)
  end

  @spec verify_auth(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_auth(token) do
    Phoenix.Token.verify(HangmanWeb.Endpoint, "auth", token, max_age: 3600)
  end
end
