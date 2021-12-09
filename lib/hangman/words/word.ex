defmodule Hangman.Words.Word do
  import Ecto.Changeset
  use Ecto.Schema
  alias Hangman.Repo

  schema "words" do
    field :word, :string
    field :difficulty, :string

    timestamps()
  end

  defp get_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id])
    |> validate_required([:id])
    |> get_word()
  end

  defp get_word(%{valid?: false} = changeset), do: changeset

  defp get_word(%{valid?: true} = changeset) do
    case Repo.get(__MODULE__, get_field(changeset, :id)) do
      nil -> add_error(changeset, :id, "Word not found")
      word -> word
    end
  end

  defp set_difficulty(%{valid?: false} = changeset), do: changeset

  defp set_difficulty(%{valid?: true} = changeset) do
    cond do
      changeset.changes == %{} ->
        changeset
      true ->
        difficulty = cond do
          String.length(changeset.changes.word) <= 5 ->
            "EASY"
          String.length(changeset.changes.word) > 5 and String.length(changeset.changes.word) <= 8 ->
            "MEDIUM"
          true ->
            "HARD"
        end
        changeset
        |> put_change(:difficulty, difficulty)
    end
  end

  defp setup_spaces(%{valid?: false} = changeset), do: changeset

  defp setup_spaces(%{valid?: true, changes: %{word: word}} = changeset) do
    changeset
    |> put_change(:word, String.upcase(String.trim(word)))
  end

  defp setup_spaces(%{valid?: true} = changeset), do: changeset

  def found_changeset(attrs) do
    attrs
    |> get_changeset()
  end

  def create_changeset(word, attrs) do
    word
    |> cast(attrs, [:word])
    |> validate_required([:word])
    |> validate_format(:word, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> validate_length(:word, min: 2, max: 30)
    |> setup_spaces()
    |> unique_constraint(:word, message: "Word already exists")
    |> set_difficulty()
  end

  def update_changeset(attrs) do
    attrs
    |> get_changeset()
    |> cast(attrs, [:word])
    |> validate_required([:word])
    |> validate_format(:word, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> validate_length(:word, min: 2, max: 30)
    |> setup_spaces()
    |> unique_constraint(:word, message: "Word already exists")
    |> set_difficulty()
  end

  def delete_changeset(attrs) do
    attrs
    |> get_changeset()
  end
end
