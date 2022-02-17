defmodule HangmanWeb.Router do
  use HangmanWeb, :router

  pipeline :api do
    plug CORSPlug,
    send_preflight_response?: false,
    origin: [
      "http://localhost:3001"
    ]
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug HangmanWeb.Auth.PipelineAccess
  end

  scope "/manager", HangmanWeb do
    pipe_through :api

    options "/", OptionsController, :options
    options "/words/:id", OptionsController, :options
    options "/words/:np/:nr", OptionsController, :options
    options "/words", OptionsController, :options
  end

  scope "/manager", HangmanWeb do
    pipe_through [:api, :auth]

    get "/words/:id", WordController, :get_word
    get "/words/:np/:nr", WordController, :get_words
    get "/words", WordController, :get_words
    post "/words", WordController, :create_word
    put "/words/:id", WordController, :update_word
    put "/words", WordController, :update_word
    delete "/words/:id", WordController, :delete_word
    delete "/words", WordController, :delete_word
  end

  scope "/game", HangmanWeb do
    pipe_through :api

    options "/word", OptionsController, :options
    options "/word/:difficulty", OptionsController, :options

    get "/word/:difficulty", WordController, :get_word_game
    get "/word", WordController, :get_word_game
  end

  # coveralls-ignore-start
  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Words API"
      }
    }
  end
  # coveralls-ignore-stop

  scope "/manager/doc" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
    otp_app: :hangman,
    swagger_file: "swagger.json"
  end
end
