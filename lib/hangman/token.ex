defmodule Hangman.Token do

  @spec auth_sign(map()) :: binary()
  def auth_sign(data) do
    Phoenix.Token.sign("VAMWT81mVrqjNQ8qSNlnQIls5PFnZFHe", "auth", data)
  end

  @spec verify_auth(String.t()) :: {:ok, any()} | {:error, :unauthenticated}
  def verify_auth(token) do
    Phoenix.Token.verify("VAMWT81mVrqjNQ8qSNlnQIls5PFnZFHe", "auth", token, max_age: 3600)
  end
end
