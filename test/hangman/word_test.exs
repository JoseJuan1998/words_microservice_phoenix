defmodule Hangman.WordTest do
  use Hangman.DataCase

  alias Hangman.Words
  alias Hangman.Words.Word

  ## MIX_ENV=test mix coveralls
  ## MIX_ENV=test mix coveralls.html

  # --- Unit Tests -------------------------------------------------------------------------------

  describe "[Unit] create_word():" do
    setup do
      {:ok, word} = Words.create_word(%{"word" => "apple"})
      {:ok, word: word}
    end

    test "Returns the word easy created" do
      changeset = Words.change_word(%Word{}, %{"word" => "lion"})
      assert changeset.valid? == true
    end

    test "Returns the word medium created" do
      changeset = Words.change_word(%Word{}, %{"word" => "elephant"})
      assert changeset.valid? == true
    end

    test "Returns the word hard created" do
      changeset = Words.change_word(%Word{}, %{"word" => "spiderman"})
      assert changeset.valid? == true
    end

    test "Error when 'word' already exists" do
      {:error, changeset} = Words.create_word(%{"word" => "apple"})
      assert changeset.valid? == false
      Hangman.DataCase.errors_on(changeset)
    end

    test "Error when 'word' is empty" do
      changeset = Words.change_word(%Word{},%{})
      assert changeset.valid? == false
    end

    test "Error when 'word' is invalid format" do
      changeset = Words.change_word(%Word{},%{"word" => "5454"})
      assert changeset.valid? == false
    end
  end

  describe "[Unit] get_words():" do
    setup do
      {:ok, word} = Words.create_word(%{"word" => "apple"})
      {:ok, word: word}
    end

    test "Returns all words" do
      words = Words.list_words(%{"np" => "1", "nr" => "5"})
      assert words != []
    end

    test "Error words is empty" do
      words = Words.list_words()
      assert words == []
    end
  end

  describe "[Unit] get_word_game():" do
    setup do
      {:ok, word} = Words.create_word(%{"word" => "apple"})
      {:ok, word: word}
    end

    test "Returns a word with difficulty" do
      words = Words.list_word_game(%{"difficulty" => "EASY"})
      assert words != []
    end

    test "Returns a word without difficulty" do
      words = Words.list_word_game()
      assert words != []
    end

    test "Error when word is not found" do
      words = Words.list_word_game(%{"difficulty" => "FSFSDF"})
      assert words == []
    end
  end

  describe "[Unit] get_word():" do
    setup do
      {:ok, word} = Words.create_word(%{"word" => "apple"})
      {:ok, word: word}
    end

    test "Returns the word found", %{word: word} do
      word_found = Words.get_word(%{"id" => word.id})
      assert not is_nil(word_found)
    end

    test "Error when 'id' is wrong", %{word: word} do
      changeset = Words.get_word(%{"id" => word.id+1})
      assert changeset.valid? == false
    end
  end

  describe "[Unit] update_word():" do
    setup do
      {:ok, word} = Words.create_word(%{"word" => "apple"})
      {:ok, word: word}
    end

    test "Returns the word updated", %{word: word} do
      {:ok, word_updated} = Words.update_word(%{"id" => word.id, "word" => "lion"})
      Words.update_word(%{"id" => word.id, "word" => "lion"})
      assert not is_nil(word_updated)
    end

    test "Error when 'id' is wrong", %{word: word} do
      {:error, changeset} = Words.update_word(%{"id" => word.id+1, "word" => "lion"})
      assert changeset.valid? == false
    end

    test "Error when 'id' is empty" do
      {:error, changeset} = Words.update_word(%{"word" => "lion"})
      assert changeset.valid? == false
    end
  end

  describe "[Unit] delete_word():" do
    setup do
      {:ok, word} = Words.create_word(%{"word" => "apple"})
      {:ok, word: word}
    end

    test "Returns the word deleted", %{word: word} do
      {:ok, word_deleted} = Words.delete_word(%{"id" => word.id})
      assert not is_nil(word_deleted)
    end

    test "Error when 'id' is wrong", %{word: word} do
      {:error, changeset} = Words.delete_word(%{"id" => word.id+1})
      assert changeset.valid? == false
    end

    test "Error when 'id' is empty" do
      {:error, changeset} = Words.delete_word()
      assert changeset.valid? == false
    end
  end
end
