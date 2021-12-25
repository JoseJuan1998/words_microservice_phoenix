defmodule HangmanWeb.WordController do
  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger
  use HangmanWeb, :controller
  alias Hangman.Words
  alias Hangman.Words.Word
  alias Hangman.Token

  action_fallback HangmanWeb.WordErrorController

  plug :authenticate_api_user when action in [:get_word, :get_words, :create_word, :update_word, :delete_word]

  # coveralls-ignore-start


  swagger_path :get_words do
    get("/manager/words/{np}/{nr}?char={char}&field={field}&order={order}")
    summary("All words")
    description("Returns JSON with all words requested")
    parameters do
      authorization :header, :string, "Token to access", required: true
      np :path, :string, "The current page", required: true
      nr :path, :string, "The rows per page", required: true
      char :path, :string, "The word you want to find", required: false
      field :path, :string, "The field you want to sort", required: false
      order :path, :string, "The order you want to sort", required: false
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
        report_params = %{word: word.word}
        IO.inspect(report_params)
        rabbit_connect(report_params)
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
        [token] = get_req_header(conn, "authorization")
        {:ok, user} = Token.verify_auth(token)
        report_params = %{email: user.email, word: word.word, action: "INSERT"}
        rabbit_connect(report_params)
        report_params = %{word: word.word, user: user.email}
        rabbit_connect(report_params)
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
        [token] = get_req_header(conn, "authorization")
        {:ok, user} = Token.verify_auth(token)
        report_params = %{email: user.email, word: word.word, action: "UPDATE"}
        rabbit_connect(report_params)
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
        [token] = get_req_header(conn, "authorization")
        {:ok, user} = Token.verify_auth(token)
        report_params = %{email: user.email, word: word.word, action: "DELETE"}
        rabbit_connect(report_params)
        conn
        |> put_status(205)
        |> render("word.json", %{word: word})
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp rabbit_connect(params) do
    # options = [host: "localhost", port: 5672, virtual_host: "/", username: "prueba", password: "prueba"]
    {:ok, connection} = AMQP.Connection.open("amqp://prueba:prueba@20.127.108.224")
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, "log")
    message = JSON.encode!(params)
    AMQP.Basic.publish(channel, "", "log", message)
    IO.puts " [x] Sent JSON"
    AMQP.Connection.close(connection)
  end
end
