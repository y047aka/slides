module MyBenchmark.Runner.App exposing (Model, Msg(..), init, update, view)

import Element exposing (..)
import Element.Attributes exposing (..)
import Html exposing (Html)
import MyBenchmark as Benchmark exposing (Benchmark)
import MyBenchmark.Reporting as Reporting
import MyBenchmark.Runner.InProgress as InProgress
import MyBenchmark.Runner.Report as Report
import MyBenchmark.Runner.Text as Text
import Process
import Style exposing (..)
import Style.Color as Color
import Style.Sheet as Sheet
import Task exposing (Task)



-- MODEL


type alias Model =
    Benchmark


init : Benchmark -> () -> ( Model, Cmd Msg )
init benchmark _ =
    ( benchmark, next benchmark )



-- UPDATE


type Msg
    = Update Benchmark


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update benchmark ->
            ( benchmark, next benchmark )


breakForRender : Task x a -> Task x a
breakForRender task =
    Task.andThen (\_ -> task) (Process.sleep 0)


next : Benchmark -> Cmd Msg
next benchmark =
    if Benchmark.done benchmark then
        Cmd.none

    else
        Benchmark.step benchmark
            |> breakForRender
            |> Task.perform Update



-- VIEW


view : Model -> Html Msg
view model =
    let
        body : Element Class Variation Msg
        body =
            if Benchmark.done model then
                model
                    |> Reporting.fromBenchmark
                    |> Report.view
                    |> Element.mapAll identity ReportClass ReportVariation

            else
                model
                    |> Reporting.fromBenchmark
                    |> InProgress.view
                    |> Element.mapAll identity InProgressClass identity
    in
    Element.viewport (Style.styleSheet styles) <|
        Element.row Page
            [ width fill
            , minHeight fill
            , center
            , verticalCenter
            ]
            [ Element.el Wrapper
                [ maxWidth (px 800)
                , padding 60
                ]
                body
            ]



-- STYLE


type Class
    = Page
    | Wrapper
    | InProgressClass InProgress.Class
    | ReportClass Report.Class


type Variation
    = ReportVariation Report.Variation


styles : List (Style Class Variation)
styles =
    [ style Page (Text.body ++ [ Color.background <| Style.rgb (242 / 255) (242 / 255) (242 / 255) ])
    , style Wrapper []
    , InProgress.styles
        |> Sheet.map InProgressClass identity
        |> Sheet.merge
    , Report.styles
        |> Sheet.map ReportClass ReportVariation
        |> Sheet.merge
    ]
