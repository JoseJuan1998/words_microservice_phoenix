defmodule HangmanWeb.WordControllerTest do
  use HangmanWeb.ConnCase
  alias Hangman.Token
  alias HangmanWeb.Auth.Guardian

  setup_all do: []

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "[ANY] Token its invalid" do
    test "Error when 'token' invalid" do
      conn = build_conn()

      conn
      |> post(Routes.word_path(conn, :create_word))
      |> response(401)
    end
  end

  describe "[GET] /words/:np/:nr:" do
    setup do
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      conn = build_conn()
      conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
      |> json_response(201)
    end

    test "Returns a list of words" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.word_path(conn, :get_words, 1, 5))
        |> json_response(:ok)

      assert %{
        "words" => [%{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }]
      } = response
    end

    test "Returns a list of words matched" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.word_path(conn, :get_words, 1, 5, %{char: "a"}))
        |> json_response(:ok)

      assert %{
        "words" => [%{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }]
      } = response
    end

    test "Error when 'words' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.word_path(conn, :get_words))
        |> json_response(:ok)

      assert %{
        "error" => _error
      } = response
    end
  end

  describe "[GET] /word/:difficulty:" do
    setup do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
      |> json_response(201)
    end

    test "Returns a word with difficulty" do
      conn = build_conn()

      response =
        conn
        |> get(Routes.word_path(conn, :get_word_game, "EASY"))
        |> json_response(:ok)

      assert %{
        "word" => %{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }
      } = response
    end

    test "Returns a word without difficulty" do
      conn = build_conn()

      response =
        conn
        |> get(Routes.word_path(conn, :get_word_game))
        |> json_response(:ok)

      assert %{
        "word" => %{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }
      } = response
    end

    test "Error when 'words' is empty" do
      conn = build_conn()

      response =
        conn
        |> get(Routes.word_path(conn, :get_word_game, "FSFSDFSD"))
        |> json_response(:ok)

      assert %{
        "error" => _error
      } = response
    end
  end

  describe "[GET] /words/:id:" do
    setup do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
      |> json_response(201)

      {:ok, params: params}
    end

    test "Returns the word found", %{params: params} do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.word_path(conn, :get_word, params["word"]["id"]))
        |> json_response(:ok)

      assert %{
        "word" => %{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }
      } = response
    end

    test "Error when 'id' is wrong" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> get(Routes.word_path(conn, :get_word, 0))
        |> json_response(404)

      assert %{
        "id" => _id
      } = response
    end
  end

  describe "[POST] /words:" do
    setup do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
      |> json_response(201)

      {:ok, params: params}
    end

    test "Returns the word created" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.word_path(conn, :create_word, %{word: "lion"}))
        |> json_response(201)

      assert %{
        "word" => %{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }
      } = response
    end

    test "Error when 'word' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.word_path(conn, :create_word))
        |> json_response(400)

      assert %{
        "word" => _error
      } = response
    end

    test "Error when 'word' already exists" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
        |> json_response(400)

      assert %{
        "word" => _error
      } = response
    end

    test "Error when 'word' is invalid format" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> post(Routes.word_path(conn, :create_word, %{word: "42423"}))
        |> json_response(400)

      assert %{
        "word" => _error
      } = response
    end
  end

  describe "[PUT] /words/:id:" do
    setup do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
      |> json_response(201)

      {:ok, params: params}
    end

    test "Returns the word updated", %{params: params} do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.word_path(conn, :update_word, params["word"]["id"],%{word: "lion"}))
        |> json_response(205)

      assert %{
        "word" => %{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }
      } = response
    end

    test "Error when 'id' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.word_path(conn, :update_word, %{word: "lion"}))
        |> json_response(404)

      assert %{
        "id" => _id
      } = response
    end

    test "Error when 'id' is wrong" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> put(Routes.word_path(conn, :update_word, 0, %{word: "lion"}))
        |> json_response(404)

      assert %{
        "id" => _id
      } = response
    end
  end

  describe "[DELTE] /words/:id:" do
    setup do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      params = conn
      |> put_req_header("authorization", "Bearer "<>token)
      |> post(Routes.word_path(conn, :create_word, %{word: "apple"}))
      |> json_response(201)

      {:ok, params: params}
    end

    test "Returns the word deleted", %{params: params} do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> delete(Routes.word_path(conn, :delete_word, params["word"]["id"]))
        |> json_response(205)

      assert %{
        "word" => %{
          "id" => _id,
          "word" => _word,
          "difficulty" => _difficulty
        }
      } = response
    end

    test "Error when 'id' is empty" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> delete(Routes.word_path(conn, :delete_word))
        |> json_response(404)

      assert %{
        "id" => _id
      } = response
    end

    test "Error when 'id' is wrong" do
      conn = build_conn()
      {:ok, token, _} = Guardian.test_token_auth(%{name: "Juan", id: 1, lastname: "Rincon", email: "juan@mail.com"})
      response =
        conn
        |> put_req_header("authorization", "Bearer "<>token)
        |> delete(Routes.word_path(conn, :delete_word, 0))
        |> json_response(404)

      assert %{
        "id" => _id
      } = response
    end
  end
end
