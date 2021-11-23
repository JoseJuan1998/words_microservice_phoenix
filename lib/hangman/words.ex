defmodule Hangman.Words do
  import Ecto.Query, warn: false
  alias Hangman.Repo
  alias Hangman.Words.Word

  def list_words(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["np"]) and not is_nil(attrs["nr"]) ->
        from u in Word, offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      true ->
        from u in Word, offset: 0, limit: 0, select: u
    end
    Repo.all(query)
  end

  def get_word(attrs \\ %{}) do
    attrs
    |> Word.found_changeset()
  end

  def create_word(attrs \\ %{}) do
    %Word{}
    |> Word.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_word(attrs \\ %{}) do
    attrs
    |> Word.update_changeset()
    |> Repo.update()
  end

  def delete_word(attrs \\ %{}) do
    attrs
    |> Word.delete_changeset()
    |> Repo.delete()
  end

  def change_word(%Word{} = word, attrs \\ %{}) do
    word
    |> Word.create_changeset(attrs)
  end
end
