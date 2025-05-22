module Custom.Benchmark exposing (Model, Msg, init, update, view)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import MyBenchmark exposing (Benchmark)
import MyBenchmark.Runner.App as App



-- MODEL


type alias Model =
    App.Model


init : Benchmark -> Model
init benchmark =
    benchmark



-- UPDATE


type alias Msg =
    App.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    App.update msg model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ App.view model
        , button [ onClick (App.Update model) ] [ text "Start" ]
        ]
