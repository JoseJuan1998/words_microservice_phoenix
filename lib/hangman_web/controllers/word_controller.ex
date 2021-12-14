defmodule HangmanWeb.WordController do
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger
  use HangmanWeb, :controller
  alias Hangman.Words
  alias Hangman.Words.Word

  action_fallback HangmanWeb.WordErrorController

  plug :authenticate_api_user when action in [:get_word, :get_words, :create_word, :update_word, :delete_word]

  # coveralls-ignore-start
  def swagger_definitions do
    %{
      Word:
        swagger_schema do
          title("Word")
          description("Words to handle")

          properties do
            id(:integer, "Words ID")
            word(:string, "Word text", required: true)
            difficulty(:string, "Difficulty of the word")
            inserted_at(:string, "Creation timestamp", format: :datetime)
            updated_at(:string, "Update timestamp", format: :datetime)
          end
        end,
      GetWordsResponse:
        swagger_schema do
          title("GetWordsResponse")
          description("Response of pagination")
          example(%{
            words: [
              %{
                id: 1,
                word: "APPLE",
                difficulty: "EASY"
              }
            ]
          })
        end,
      GetWordsResponseError:
        swagger_schema do
          title("GetWordsResponseError")
          description("Response of error")
          example(%{
            error: "There are no words"
          })
        end,
      GetWordGameResponse:
        swagger_schema do
          title("GetWordGameResponse")
          description("Response of word for game")
          example(%{
            word: %{
              id: 1,
              word: "APPLE",
              difficulty: "EASY"
            }
          })
        end,
      GetWordGameResponseError:
        swagger_schema do
          title("GetWordGameResponseError")
          description("Response of error")
          example(%{
            error: "There are no words"
          })
        end,
      GetWordRequest:
        swagger_schema do
          title("GetWordRequest")
          description("GET to get word")
        end,
      GetWordResponse:
        swagger_schema do
          title("GetWordResponse")
          description("Response of word")
          example(%{
            word:
              %{
                id: 1,
                word: "APPLE",
                difficulty: "EASY"
              }
          })
        end,
      GetWordResponseError:
        swagger_schema do
          title("GetWordResponseError")
          description("Response of error")
          example(%{
            id: "Word not found"
          })
        end,
      CreateWordRequest:
        swagger_schema do
          title("CreateWordRequest")
          description("POST body to create a word")
          property(:words, Schema.array(:Word), "The word text")
          example(%{
            word: "APPLE"
          })
        end,
      CreateWordResponse:
        swagger_schema do
          title("CreateWordResponse")
          description("Response schema of the word created")
          property(:words, Schema.array(:Word), "The word created")
          example(%{
            word: %{
              id: 1,
              word: "APPLE",
              difficulty: "EASY"
            }
          })
        end,
      CreateWordResponseError:
        swagger_schema do
          title("CreateWordResponseError")
          description("Response schema of errors")
          property(:words, Schema.array(:Word), "The word created")
          example(%{
            word1: "word can't be blank",
            word2: "word already exists"
          })
        end,
      UpdateWordRequest:
        swagger_schema do
          title("UpdateWordRequest")
          description("PUT body to update a word")
          property(:words, Schema.array(:Word), "The word text")
          example(%{
            word: "ELEPHANT"
          })
        end,
      UpdateWordResponse:
        swagger_schema do
          title("UpdateWordResponse")
          description("Response schema of the word updated")
          property(:words, Schema.array(:Word), "The word created")
          example(%{
            word: %{
              id: 1,
              word: "ELEPHANT",
              difficulty: "MEDIUM"
            }
          })
        end,
      UpdateWordResponseError:
        swagger_schema do
          title("UpdateWordResponseError")
          description("Response schema of errors")
          property(:words, Schema.array(:Word), "The word updated")
          example(%{
            word: "can't be blank",
            id1: "Word not found",
            id2: "can't be blank"
          })
        end,
      DeleteWordRequest:
        swagger_schema do
          title("DeleteWordRequest")
          description("DELETE to delete word")
        end,
      DeleteWordResponse:
        swagger_schema do
          title("DeleteWordResponse")
          description("Response of word")
          example(%{
            word:
              %{
                id: 1,
                word: "APPLE",
                difficulty: "EASY"
              }
          })
        end,
      DeleteWordResponseError:
        swagger_schema do
          title("DeleteWordResponseError")
          description("Response of error")
          example(%{
            id1: "word not found",
            id2: "can't be blank"
          })
        end,
    }
  end

  swagger_path :get_words do
    get("/manager/words/{np}/{nr}?char={char}")
    summary("All words")
    description("Returns JSON with all words requested")
    parameters do
      authorization :header, :string, "Token to access", required: true
      np :path, :string, "The current page", required: true
      nr :path, :string, "The rows per page", required: true
      char :path, :string, "The word you want to find", required: false
    end
    response(200, "Success", Schema.ref(:GetWordsResponse))
    response(204, "No words" ,Schema.ref(:GetWordsResponseError))
  end
  # coveralls-ignore-stop

  def get_words(conn, params) do
    words = Words.list_words(params)
    case words != [] do
      true ->
        count = Words.count_words(params)
        conn
        |> put_status(200)
        |> render("words.json", %{count: count, words: words})
      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no words"})
    end
  end

  # coveralls-ignore-start
  swagger_path :get_word_game do
    get("/game/word/{difficulty}")
    summary("An specif word by difficulty")
    description("Returns JSON with word requested")
    parameters do
      difficulty :path, :string, "The current difficulty"
    end
    response(200, "Success", Schema.ref(:GetWordGameResponse))
    response(204, "No word" ,Schema.ref(:GetWordGameResponseError))
  end
  # coveralls-ignore-stop

  def get_word_game(conn, params) do
    words = Words.list_word_game(params)
    case words != [] do
      true ->
        word = Enum.at(words, 0)
        conn
        |> put_status(200)
        |> render("word.json", %{word: word})
      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no word"})
    end
  end

  # coveralls-ignore-start
  swagger_path :get_word do
    get("/manager/words/{id}")
    summary("One word")
    description("Returns JSON with word requested")
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the word", required: true
    end
    response(200, "Success", Schema.ref(:GetWordResponse))
    response(404, "No word found" ,Schema.ref(:GetWordResponseError))
  end
  # coveralls-ignore-stop

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

  # coveralls-ignore-start
  swagger_path :create_word do
    post("/manager/words")
    summary("Create word")
    description("Returns JSON with word created")
    parameters do
      authorization :header, :string, "Token to access", required: true
      word :body, Schema.ref(:CreateWordRequest), "The word data", required: true
    end
    response(200, "Success", Schema.ref(:CreateWordResponse))
    response(400, "Bad Request" ,Schema.ref(:CreateWordResponseError))
  end
  # coveralls-ignore-stop

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

  # coveralls-ignore-start
  swagger_path :update_word do
    put("/manager/words/{id}")
    summary("Update word")
    description("Returns JSON with word updated")
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the word to update", required: true
      word :body, Schema.ref(:UpdateWordRequest), "The word data", required: true
    end
    response(200, "Success", Schema.ref(:UpdateWordResponse))
    response(400, "Bad Request" ,Schema.ref(:UpdateWordResponseError))
  end
  # coveralls-ignore-stop

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

  # coveralls-ignore-start
  swagger_path :delete_word do
    delete("/manager/words/{id}")
    summary("Delete word")
    description("Returns JSON with word deleted")
    parameters do
      authorization :header, :string, "Token to access", required: true
      id :path, :string, "The id of the word to delete", required: true
    end
    response(200, "Success", Schema.ref(:DeleteWordResponse))
    response(400, "Bad Request" ,Schema.ref(:DeleteWordResponseError))
  end
  # coveralls-ignore-stop

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
