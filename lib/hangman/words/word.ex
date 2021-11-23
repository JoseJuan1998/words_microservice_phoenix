defmodule Hangman.Words.Word do
  import Ecto.Changeset
  use Ecto.Schema
  alias Hangman.Repo

  schema "words" do
    field :word, :string

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

  def found_changeset(attrs) do
    attrs
    |> get_changeset()
  end

  def create_changeset(word, attrs) do
    word
    |> cast(attrs, [:word])
    |> validate_required([:word])
    |> validate_format(:word, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> unique_constraint(:word, message: "Word already exists")
  end

  def update_changeset(attrs) do
    attrs
    |> get_changeset()
    |> cast(attrs, [:word])
    |> validate_required([:word])
  end

  def delete_changeset(attrs) do
    attrs
    |> get_changeset()
  end
end
