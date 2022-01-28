defmodule Hangman.Words do
  import Ecto.Query, warn: false
  alias Hangman.Repo
  alias Hangman.Words.Word

  def count_words(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["char"]) ->
        from u in search(attrs), select: count(u)
      true ->
        from u in Word, select: count(u)
      end
      Repo.one(query)
  end

  def list_words(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["np"]) and not is_nil(attrs["nr"]) ->
        get_pagination(attrs)
      true ->
        from u in Word, offset: 0, limit: 0, select: u
    end
    Repo.all(query)
  end

  def list_word_game(attrs \\ %{}) do
    query = cond do
      not is_nil(attrs["difficulty"]) ->
        from u in Word, where: u.difficulty == ^String.upcase(attrs["difficulty"]), order_by: fragment("RANDOM()"), limit: 1, select: u
      true ->
        from u in Word, order_by: fragment("RANDOM()"), limit: 1, select: u
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

  defp get_pagination(attrs) do
    cond do
      not is_nil(attrs["char"]) ->
        from u in search(attrs), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
      not is_nil(attrs["field"]) and not is_nil(attrs["order"]) ->
        get_field(attrs)
      true ->
        paginate(attrs)
    end
  end

  defp get_field(attrs) do
    case String.to_atom(String.downcase(attrs["field"])) do
      :word ->
        get_sorting(attrs)
      _other ->
        paginate(attrs)
    end
  end

  defp get_sorting(attrs) do
    case String.to_atom(String.upcase(attrs["order"])) do
      :ASC ->
        sort(:asc, attrs)
      :DESC ->
        sort(:desc, attrs)
      _other ->
        paginate(attrs)
    end
  end

  defp sort(order, attrs) do
    from u in Word, order_by: ^Keyword.new([{order, String.to_atom(String.downcase(attrs["field"]))}]), offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  end

  defp search(attrs) do
    from u in Word, where: like(u.word, ^"%#{String.trim(String.upcase(attrs["char"]))}%")
  end

  defp paginate(attrs) do
    from u in Word, order_by: [asc: u.word], offset: ^((String.to_integer(attrs["np"]) - 1) * (String.to_integer(attrs["nr"]))), limit: ^attrs["nr"], select: u
  end
end
