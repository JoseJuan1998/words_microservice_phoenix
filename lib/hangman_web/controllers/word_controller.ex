defmodule HangmanWeb.WordController do
  use HangmanWeb, :controller
  alias Hangman.Words
  alias Hangman.Words.Word

  action_fallback HangmanWeb.WordErrorController

  plug :authenticate_api_user when action in [:create_word, :update_word, :delete_word]

  def get_words(conn, params) do
    words = Words.list_words(params)
    case words != [] do
      true ->
        conn
        |> put_status(200)
        |> render("words.json", %{words: words})
      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no words"})
    end
  end

  def get_word(conn, params) do
    case Words.get_word(params) do
      %Word{} = word ->
        conn
        |> put_status(200)
        |> render("word.json", %{word: word})
      %Ecto.Changeset{} = changeset ->
        {:error, changeset}
    end
  end

  def create_word(conn, params) do
    case Words.create_word(params) do
      {:ok, word} ->
        conn
        |> put_status(201)
        |> render("word.json", %{word: word})
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_word(conn, params) do
    case Words.update_word(params) do
      {:ok, word} ->
        conn
        |> put_status(205)
        |> render("word.json", %{word: word})
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete_word(conn, params) do
    case Words.delete_word(params) do
      {:ok, word} ->
        conn
        |> put_status(205)
        |> render("word.json", %{word: word})
      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
