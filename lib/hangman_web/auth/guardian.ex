defmodule HangmanWeb.Auth.Guardian do
  use Guardian, otp_app: :hangman

  def subject_for_token(user, _claims), do: {:ok, to_string((user.id))}

  def resource_from_claims(claims) do
    claims["sub"]
  end

  def test_token_auth(user) do
    create_token(user)
  end

  defp create_token(user) do
   {:ok, token, _claims} = encode_and_sign(user, %{email: user.email})
   {:ok, token, user}
  end
end
