defmodule HangmanWeb.WordView do
  use HangmanWeb, :view

  def render("word.json", %{word: word}) do
    %{word: render("single_word.json", %{word: word})}
  end

  def render("words.json", %{words: words}) do
    %{words: render_many(words, HangmanWeb.WordView, "single_word.json")}
  end

  def render("single_word.json", %{word: word}) do
    %{
      id: word.id,
      word: word.word,
      difficulty: word.difficulty
    }
  end
end
