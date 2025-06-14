module Custom.Benchmark exposing (Model, Msg, init, update, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled exposing (button, div, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
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
    Html.Styled.toUnstyled <|
        div
            [ css
                [ displayFlex
                , flexDirection column
                , property "row-gap" "10px"
                ]
            ]
            [ button
                [ onClick (App.Update model)
                , css
                    [ zIndex (int 1000)
                    , marginLeft auto
                    ]
                ]
                [ text "Start" ]
            , div [ css [ overflow hidden, borderRadius (px 10) ] ]
                [ Html.Styled.fromUnstyled (App.view model) ]
            ]
