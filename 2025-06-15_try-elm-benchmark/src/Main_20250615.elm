module Main_20250615 exposing (main)

import Array exposing (Array)
import Array.Extra2
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Css exposing (..)
import Csv.Decode as CD exposing (FieldNames(..))
import Custom exposing (Content, Msg)
import Data.Fixture.Csv as Fixture
import Data.Fixture.Json as Fixture
import Data.Wec
import Data.Wec.Decoder as Wec
import Data.Wec.Preprocess
import Data.Wec.Preprocess.Beginning as Beginning
import Data.Wec.Preprocess.Dict
import Formatting.Styled as Formatting exposing (Tag(..), background, colored, highlightElm, markdown, markdownPage, nextButton, page, prevButton, spacer, tagCloud)
import Html.Styled as Html exposing (br, div, h1, img, span, text)
import Html.Styled.Attributes exposing (css, src)
import Json.Decode as JD
import MyBenchmark as Benchmark
import SliceShow exposing (Message, Model, init, item, setDimensions, setSubscriptions, setUpdate, setView, show)
import Svg
import SyntaxHighlight exposing (Highlight(..), highlightLines)


main : Program () (Model Custom.Model Msg) (Message Msg)
main =
    init slides
        |> setDimensions ( 1280, 720 )
        |> setSubscriptions Custom.subscriptions
        |> setView Custom.view
        |> setUpdate Custom.update
        |> show


slides : List (List Content)
slides =
    [ [ cover

      -- はじめに
      , introduction
      , elmTagCloud
      , elmMotorsportAnalysis
      , elmMotorsportAnalysis_image
      , motivation
      ]
    , chapter "ベンチマーク測定の方法"
        "P1001668.jpeg"
        [ benchmark_overview
        , elmBenchmark
        ]
    , chapter "ベンチマーク測定してみよう！"
        "le_mans_24h_csv.png"
        [ oldWorkflow
        , oldWorkflow_code
        , oldWorkflow_benchmark
        , oldWorkflow_benchmark_chart
        , optimization_ideas
        ]
    , chapter "改善① List を Array に置き換える"
        "P1002085.jpeg"
        [ replaceWithArray_overview
        , replaceWithArray_benchmark
        , replaceWithArray_benchmark_chart
        , replaceWithArray_sortBy
        , replaceWithArray_sortBy_benchmark
        , replaceWithArray_sortBy_benchmark_chart
        ]
    , chapter "改善② AssocList を Dict に置き換える"
        "P1002442.jpeg"
        [ replaceWithDict_overview
        , replaceWithDict_code
        , replaceWithDict_ordersByLap_benchmark
        , replaceWithDict_ordersByLap_benchmark_chart
        , replaceWithDict_preprocessHelper_benchmark
        , replaceWithDict_preprocessHelper_benchmark_chart
        ]
    , chapter "改善③ 計算ロジックを改良する"
        "P1002755.jpeg"
        [ improve_logic_overview
        , improve_logic_code_old
        , improve_logic_code
        , improve_logic_laps_benchmark
        , improve_logic_laps_benchmark_chart
        , improve_logic_preprocessHelper_benchmark
        , improve_logic_preprocessHelper_benchmark_chart
        , improve_logic_benchmark
        , improve_logic_benchmark_chart
        ]
    , chapter "改善④ 入力データ形式の変更"
        "P1003304.jpeg"
        [ replaceWithJson_overview
        , replaceWithJson_benchmark
        , replaceWithJson_benchmark_chart
        ]
    , chapter "改善⑤ その他の選択肢"
        "P1002574.jpeg"
        [ cli ]
    , chapter "ベンチマークから得られた知見"
        ""
        [ lessonsLearned ]
    , [ conclusion ]
    ]
        |> List.concat
        |> List.map addMobileNavigationButtons


addMobileNavigationButtons : List Content -> List Content
addMobileNavigationButtons contents =
    contents
        ++ [ prevButton ( 100, 720 ) |> Formatting.position 0 0
           , nextButton ( 100, 720 ) |> Formatting.position (1280 - 100) 0
           ]


cover : List Content
cover =
    [ colored
        "hsl(200, 100%, 40%)"
        "#FFF"
        [ h1 []
            [ span
                [ css [ fontSize (rem 5.5) ] ]
                [ text "Elmのパフォーマンス、実際どうなの？" ]
            , spacer 20
            , span [ css [ lineHeight (num 1.1), fontSize (rem 15) ] ]
                [ text "ベンチマークに"
                , br [] []
                , text "入門してみた"
                ]
            ]
        , div
            [ css
                [ displayFlex
                , alignItems center
                , property "column-gap" "10px"
                ]
            ]
            [ img
                [ src "assets/images/y047aka.png"
                , css [ width (px 50), borderRadius (pct 50) ]
                ]
                []
            , span [ css [ fontSize (rem 3) ] ]
                [ text "Yoshitaka Totsuka" ]
            ]
        , spacer 15
        , div
            [ css
                [ displayFlex
                , alignItems baseline
                , property "column-gap" "10px"
                ]
            ]
            [ span [] [ text "関数型まつり2025" ]
            , span [] [ text "2025-06-14" ]
            ]
        ]
    ]


chapter : String -> String -> List (List Content) -> List (List Content)
chapter titleText bgImagePath contents =
    [ background ("assets/images/2025-06-15_try-elm-benchmark/" ++ bgImagePath)
        [ div
            [ css
                [ height (pct 100)
                , property "display" "grid"
                , property "place-items" "center"
                ]
            ]
            [ h1
                [ css
                    [ textAlign center
                    , fontSize (em 1.5)
                    , fontWeight bold
                    ]
                ]
                [ text titleText ]
            ]
        ]
    ]
        :: contents


introduction : List Content
introduction =
    page
        { chapter = "はじめに"
        , title = "発表の流れ"
        }
        [ markdownPage """
- Elmってどんな言語？
- ベンチマーク測定方法の説明
- 最適化の試み
    - List を Array に置き換える
    - AssocList を Dict に置き換える
    - 計算ロジックを改良する
    - 入力データ形式の変更
"""
        ]


elmTagCloud : List Content
elmTagCloud =
    page
        { chapter = "はじめに"
        , title = "Elmってどんな言語？"
        }
        [ tagCloud
            [ -- 関数型言語共通の項目
              Green 2.5 "静的型付け"
            , Green 1.8 "型安全"
            , Gray 2.2 "純粋関数型"
            , Gray 1.8 "イミュータブル"
            , Green 1.8 "Maybe型"
            , Green 1.8 "Result型"
            , Green 1.8 "代数的データ型"
            , Green 2.0 "パターンマッチング"
            , Green 1.8 "パイプ演算子"
            , Gray 1.8 "型推論"

            -- Elm固有の項目
            , Gray 2.5 "フロントエンド開発に特化"
            , Gray 2.6 "JavaScriptにコンパイルされる"
            , Green 3.2 "The Elm Architecture"
            , Green 3.0 "実行時エラーが起きにくい"
            , Green 2.4 "言語仕様がシンプルで学びやすい"
            , Gray 2.2 "型クラスがない"
            , Green 2.2 "タイムトラベルデバッガ"
            , Gray 2.2 "JavaScriptとの連携はPortを介して行う"
            , Green 2.2 "エラーメッセージが親切"
            , Red 2.2 "ボイラープレートの記述が多い"
            ]
        ]


elmMotorsportAnalysis : List Content
elmMotorsportAnalysis =
    page
        { chapter = "はじめに"
        , title = "今回の題材"
        }
        [ markdownPage """
## elm-motorsport-analysis

自分用に開発しているモータースポーツのレビュー用アプリケーションです

- レースの周回データを分析・可視化
- 各車両の順位変動やラップタイムを比較
- 大量の周回データを扱うため、パフォーマンスが気になった
    - とくに困っているわけではないです
"""
        ]


elmMotorsportAnalysis_image : List Content
elmMotorsportAnalysis_image =
    page
        { chapter = "はじめに"
        , title = "elm-motorsport-analysis"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ Css.height (pct 100)
                        , borderRadius (px 10)
                        , Css.property "background-image"
                            ("url('"
                                ++ "assets/images/2025-06-15_try-elm-benchmark/"
                                ++ "elm_motorsport_analysis.png"
                                ++ "')"
                            )
                        , backgroundSize Css.cover
                        , backgroundRepeat noRepeat
                        ]
                    ]
                    []
        ]


motivation : List Content
motivation =
    page
        { chapter = "はじめに"
        , title = "ベンチマーク測定の動機"
        }
        [ markdownPage """
## ベンチマークテストを体験してみたい

- `List` と `Array` のパフォーマンスの違いを体感する
    - 1万行以上のデータを扱うので、Arrayの優位性を体感できそう？
- 非効率なコードが残っているうちに試したい
    - 改善の幅が大きいほうが楽しい
    - アプリケーションの機能追加を予定していたので、その前に挑戦したい
"""
        ]


benchmark_overview : List Content
benchmark_overview =
    page
        { chapter = "ベンチマーク測定の方法"
        , title = "概要"
        }
        [ markdownPage """
## ベンチマークテストの目的

- システムの性能を評価する
- 異なる実装アプローチでの性能を比較する
- ボトルネックを特定する

## 測定時の注意事項

同じ条件で測定すれば、常に同じ結果が得られるように

- 測定環境の統一：CPU、メモリ、ネットワーク環境などの条件を揃える
- 統計的な有意性：十分なサンプル数の確保、外れ値の除外
"""
        ]


elmBenchmark : List Content
elmBenchmark =
    page
        { chapter = "ベンチマーク測定の方法"
        , title = "elm-explorations/benchmark"
        }
        [ markdownPage """
## 測定環境の最適化

- 測定前にJITコンパイルを強制し、最適化あり/なしのコードの混在を防ぐ

## 統計的に有意な結果を提供

- 十分なサンプル数を得るまで反復実行
- 複数対象を交互に実行し、測定の偏りを軽減
- 外れ値を除外する
"""
        ]


oldWorkflow : List Content
oldWorkflow =
    page
        { chapter = "ベンチマーク測定してみよう！"
        , title = "データ処理の流れ"
        }
        [ markdownPage """
1. CSVデータの読み込み＆デコード
    - ル・マン24時間レース（2024年）の走行データ
    - 周回データとしてデコード
3. データの前処理（`preprocess`）
    - 車両単位での再構成
    - 計算量の多い分析を最初に済ませておく（`preprocessHelper`）
"""
        ]


oldWorkflow_code : List Content
oldWorkflow_code =
    page
        { chapter = "ベンチマーク測定してみよう！"
        , title = "CSVをパースし、周回データとしてデコード"
        }
        [ markdownPage """
- 周回データを解析し、車両単位で再構成
"""
        , highlightElm identity """preprocess : List Lap -> List Car
preprocess laps =
    laps
        |> AssocList.Extra.groupBy .carNumber
        |> AssocList.toList
        |> List.map
            (\\( carNumber, laps_ ) ->
                preprocessHelper_old
                    { carNumber = carNumber
                    , laps = ...
                    , startPositions = ...
                    , ordersByLap = ...
                    }
            )"""
        ]


oldWorkflow_benchmark : List Content
oldWorkflow_benchmark =
    page
        { chapter = "ベンチマーク測定してみよう！"
        , title = "ベンチマーク：preprocess"
        }
        [ Custom.benchmark <|
            Benchmark.describe "Data.Wec.Preprocess"
                [ Benchmark.scale "old"
                    ([ 10 -- 89,854 runs/s (GoF: 99.79%)
                     , 100 -- 1,719 runs/s (GoF: 99.97%)

                     --  , 1000 -- 70 runs/s (GoF: 99.97%)
                     --    2500 -- 29 runs/s (GoF: 99.99%)
                     --    5000 -- 13 runs/s (GoF: 99.99%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.preprocess target ))
                    )
                , let
                    options =
                        { carNumber = "15"
                        , laps = Fixture.csvDecodedForCarNumber "15"
                        , startPositions = Beginning.startPositions_list Fixture.csvDecoded
                        , ordersByLap = Beginning.ordersByLap_list Fixture.csvDecoded
                        }
                  in
                  Benchmark.benchmark "preprocessHelper"
                    (\_ ->
                        -- 375 runs/s (GoF: 100%)
                        Beginning.preprocessHelper options
                    )
                ]
        ]


toString : Int -> String
toString n =
    "n = " ++ String.fromInt n


oldWorkflow_benchmark_chart : List Content
oldWorkflow_benchmark_chart =
    page
        { chapter = "ベンチマーク測定してみよう！"
        , title = "測定結果：preprocess"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24, CA.format formatWithCommas ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 89854 }
                                , { x = 100, y = 1719 }
                                , { x = 1000, y = 70 }
                                , { x = 2500, y = 29 }
                                , { x = 5000, y = 13 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 20
                                , CA.format (\item -> CI.getData item |> .y |> formatWithCommas)
                                ]
                            ]
                    ]
        ]


{-| 対数変換用の補助関数
-}
logarithmic : Float -> Float
logarithmic number =
    logBase 10 number


exponential : Float -> Float
exponential n =
    toFloat (Basics.round (10 ^ n))


{-| 数値を桁区切りを含めた文字列に変換する関数
高階関数を活用した関数型プログラミングらしい実装
-}
formatWithCommas : Float -> String
formatWithCommas number =
    let
        ( integerPart, decimalPart ) =
            case String.split "." (String.fromFloat number) of
                integerPart_ :: decimalPart_ :: tails ->
                    ( integerPart_, Just (String.join "." (decimalPart_ :: tails)) )

                [ integerPart_ ] ->
                    ( integerPart_, Nothing )

                [] ->
                    ( "", Nothing )

        formatInteger : String -> String
        formatInteger str =
            str
                |> String.reverse
                |> chunksOfString 3
                |> List.map String.reverse
                |> List.reverse
                |> String.join ","

        chunksOfString : Int -> String -> List String
        chunksOfString size string =
            if String.isEmpty string then
                []

            else
                String.left size string :: chunksOfString size (String.dropLeft size string)
    in
    formatInteger integerPart
        ++ (Maybe.withDefault "" <| Maybe.map (\d -> "." ++ d) <| decimalPart)


optimization_ideas : List Content
optimization_ideas =
    page
        { chapter = "ベンチマーク測定してみよう！"
        , title = "パフォーマンス改善のアイデア"
        }
        [ markdownPage """
## 大量データの処理による線形時間の増加

- `List` を `Array` に置き換える
- `AssocList` による線形検索（O(n)）を `Dict` に置き換える

## 非効率な計算の繰り返し

- 計算ロジックを見直す

"""
        ]


replaceWithArray_overview : List Content
replaceWithArray_overview =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "概要"
        }
        [ markdownPage """
- Listは線形検索、Arrayはインデックスアクセスに強い
- 1万行以上のデータを扱うので、Arrayの優位性を体感できそう
"""
        , highlightElm
            (highlightLines (Just Del) 3 4
                >> highlightLines (Just Add) 4 5
                >> highlightLines (Just Del) 6 7
                >> highlightLines (Just Add) 7 9
            )
            """{-| スタート時の各車両の順位を求める関数
    暫定的に1周目の通過タイムの早かった順で代用している
-}
startPositions : List Lap -> List String
startPositions : Array WecLap -> List String
startPositions laps =
    List.filter (\\{ lapNumber } -> lapNumber == 1) laps
    Array.filter (\\{ lapNumber } -> lapNumber == 1) laps
        |> Array.toList
        |> List.sortBy .elapsed
        |> List.map .carNumber"""
        ]


replaceWithArray_benchmark : List Content
replaceWithArray_benchmark =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "ベンチマーク：startPositions"
        }
        [ Custom.benchmark <|
            Benchmark.describe "startPositions"
                [ Benchmark.scale "List.filterを使う場合"
                    ([ 10 -- 7,867,463 runs/s (GoF: 99.68%)
                     , 100 -- 1,202,934 runs/s (GoF: 99.66%)
                     , 1000 -- 105,125 runs/s (GoF: 99.86%)

                     --  , 2500 -- 42,881 runs/s (GoF: 99.95%)
                     , 5000 -- 23,018 runs/s (GoF: 99.84%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.startPositions_list target ))
                    )
                , Benchmark.scale "Array.filterに変更"
                    ([ 10 -- 6,391,412 runs/s (GoF: 99.82%)
                     , 100 -- 1,516,647 runs/s (GoF: 99.88%)
                     , 1000 -- 182,849 runs/s (GoF: 99.89%)

                     --  , 2500 -- 68,818 runs/s (GoF: 99.96%)
                     , 5000 -- 33,334 runs/s (GoF: 99.93%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size |> Array.fromList ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> startPositions_tmp target ))
                    )
                ]
        ]


startPositions_tmp : Array Wec.Lap -> List String
startPositions_tmp laps =
    Array.filter (\{ lapNumber } -> lapNumber == 1) laps
        |> Array.toList
        |> List.sortBy .elapsed
        |> List.map .carNumber


replaceWithArray_benchmark_chart : List Content
replaceWithArray_benchmark_chart =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "測定結果：startPositions"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24, CA.format formatWithCommas ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 7867463 }
                                , { x = 100, y = 1202934 }
                                , { x = 1000, y = 105125 }
                                , { x = 2500, y = 42881 }
                                , { x = 5000, y = 23018 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 6391412 }
                                , { x = 100, y = 1516647 }
                                , { x = 1000, y = 182849 }
                                , { x = 2500, y = 68818 }
                                , { x = 5000, y = 33334 }
                                ]
                            ]
                    ]
        ]


replaceWithArray_sortBy : List Content
replaceWithArray_sortBy =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "余談：Array.sortBy 関数を自作してみる"
        }
        [ markdownPage """
## 困ったこと

- Arrayを操作する関数があまり提供されていない
    - そのため、ArrayをListに変換する処理を挟むことになる
- `Array`型のみでソートを実現した場合のパフォーマンスが気になる

## 実装の成果

- マージソートによる `sortBy` 関数を試作した
- List.sortByと同等のパフォーマンスは得られたものの、`List` に変換してソートするほうが早いという結果になった
"""
        ]


replaceWithArray_sortBy_benchmark : List Content
replaceWithArray_sortBy_benchmark =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "ベンチマーク：sortBy"
        }
        [ Custom.benchmark <|
            Benchmark.describe "sortBy"
                [ Benchmark.scale "Listに変換して List.sortBy"
                    ([ 10 -- 6,197,778 runs/s (GoF: 99.16%)
                     , 100 -- 1,261,381 runs/s (GoF: 99.78%)
                     , 1000 -- 136,169 runs/s (GoF: 99.92%)

                     --  , 2500 -- 53,081 runs/s (GoF: 99.9%)
                     , 5000 -- 26,229 runs/s (GoF: 99.85%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size |> Array.fromList ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> startPositions_tmp target ))
                    )
                , Benchmark.scale "Array.Extra2.sortBy"
                    ([ 10 -- 7,705,030 runs/s (GoF: 99.49%)
                     , 100 -- 1,212,313 runs/s (GoF: 99.54%)
                     , 1000 -- 122,188 runs/s (GoF: 99.8%)

                     --  , 2500 -- 47,325 runs/s (GoF: 99.91%)
                     , 5000 -- 22,301 runs/s (GoF: 99.83%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size |> Array.fromList ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> startPositions_array target ))
                    )
                ]
        ]


startPositions_array : Array Wec.Lap -> Array String
startPositions_array laps =
    Array.filter (\{ lapNumber } -> lapNumber == 1) laps
        |> Array.Extra2.sortBy .elapsed
        |> Array.map .carNumber


replaceWithArray_sortBy_benchmark_chart : List Content
replaceWithArray_sortBy_benchmark_chart =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "測定結果：sortBy"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24, CA.format formatWithCommas ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 6197778 }
                                , { x = 100, y = 1261381 }
                                , { x = 1000, y = 136169 }
                                , { x = 2500, y = 53081 }
                                , { x = 5000, y = 26229 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 7705030 }
                                , { x = 100, y = 1212313 }
                                , { x = 1000, y = 122188 }
                                , { x = 2500, y = 47325 }
                                , { x = 5000, y = 22301 }
                                ]
                            ]
                    ]
        ]


replaceWithDict_overview : List Content
replaceWithDict_overview =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "概要"
        }
        [ markdownPage """
## AssocList

- キーと値のペアをリストで管理（任意の型をキーにできる）
- 検索速度：線形時間が必要（O(n)）
    - データ量が増えると処理時間が比例して増加してしまう

## Dict

- ハッシュベースの実装
- 検索速度：定数時間でのアクセスが可能（O(1)）

Dictを使用して検索を定数時間（O(1)）に改善したい
"""
        ]


replaceWithDict_code : List Content
replaceWithDict_code =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "実装の変更"
        }
        [ highlightElm (highlightLines (Just Add) 7 9 >> highlightLines (Just Del) 5 7)
            """{-| 各周回での各車両の順位を求める関数
-}
ordersByLap_dict : List Wec.Lap -> OrdersByLap
ordersByLap_dict laps =
    laps
        |> AssocList.Extra.groupBy .lapNumber
        |> AssocList.toList
        |> Dict.Extra.groupBy .lapNumber
        |> Dict.toList
        |> List.map
            (\\( lapNumber, cars ) ->
                { lapNumber = lapNumber
                , order = cars |> List.sortBy .elapsed |> List.map .carNumber
                }
            )"""
        ]


replaceWithDict_ordersByLap_benchmark : List Content
replaceWithDict_ordersByLap_benchmark =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "ベンチマーク：ordersByLap"
        }
        [ Custom.benchmark <|
            Benchmark.describe "ordersByLap"
                [ Benchmark.scale "AssocList"
                    ([ 10 -- 722,799 runs/s (GoF: 99.39%)
                     , 100 -- 30,336 runs/s (GoF: 99.79%)
                     , 1000 -- 305 runs/s (GoF: 99.96%)

                     --  , 2500 -- 121 runs/s (GoF: 99.94%)
                     --  , 5000 -- 57 runs/s (GoF: 99.95%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.ordersByLap_list target ))
                    )
                , Benchmark.scale "Dict"
                    ([ 10 -- 496,866 runs/s (GoF: 99.93%)
                     , 100 -- 31,250 runs/s (GoF: 99.86%)
                     , 1000 -- 3,350 runs/s (GoF: 99.95%)

                     --  , 2500 -- 1,327 runs/s (GoF: 99.97%)
                     , 5000 -- 647 runs/s (GoF: 99.99%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Data.Wec.Preprocess.Dict.ordersByLap_dict target ))
                    )
                ]
        ]


replaceWithDict_ordersByLap_benchmark_chart : List Content
replaceWithDict_ordersByLap_benchmark_chart =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "測定結果：ordersByLap"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24 ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 722799 }
                                , { x = 100, y = 30336 }
                                , { x = 1000, y = 305 }
                                , { x = 2500, y = 121 }
                                , { x = 5000, y = 57 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 496866 }
                                , { x = 100, y = 31250 }
                                , { x = 1000, y = 3350 }
                                , { x = 2500, y = 1327 }
                                , { x = 5000, y = 647 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 16
                                , CA.format (\item -> CI.getData item |> .y |> formatWithCommas)
                                ]
                            ]
                    ]
        ]


replaceWithDict_preprocessHelper_benchmark : List Content
replaceWithDict_preprocessHelper_benchmark =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "ベンチマーク：preprocessHelper"
        }
        [ Custom.benchmark <|
            Benchmark.describe "preprocessHelper"
                [ Benchmark.scale "AssocList"
                    ([ -- 10 -- 16,080,582 runs/s (GoF: 99.73%)
                       100 -- 15,827,913 runs/s (GoF: 99.86%)

                     --  , 1000 -- 428 runs/s (GoF: 99.98%)
                     --  , 2500 -- 428 runs/s (GoF: 99.99%)
                     , 5000 -- 425 runs/s (GoF: 99.98%)
                     ]
                        |> List.map
                            (\size ->
                                ( size
                                , let
                                    decoded =
                                        Fixture.csvDecodedOfSize size
                                  in
                                  { carNumber = "15"
                                  , laps = List.filter (\{ carNumber } -> carNumber == "15") decoded
                                  , startPositions = Beginning.startPositions_list decoded
                                  , ordersByLap = Beginning.ordersByLap_list decoded
                                  }
                                )
                            )
                        |> List.map (\( size, options ) -> ( toString size, \_ -> Beginning.preprocessHelper options ))
                    )
                , Benchmark.scale "Dict"
                    ([ -- 10 -- 15,880,402 runs/s (GoF: 99.78%)
                       100 -- 15,428,292 runs/s (GoF: 99.33%)

                     --  , 1000 -- 423 runs/s (GoF: 99.97%)
                     --  , 2500 -- 421 runs/s (GoF: 99.96%)
                     , 5000 -- 420 runs/s (GoF: 99.96%)
                     ]
                        |> List.map
                            (\size ->
                                ( size
                                , let
                                    decoded =
                                        Fixture.csvDecodedOfSize size
                                  in
                                  { carNumber = "15"
                                  , laps = List.filter (\{ carNumber } -> carNumber == "15") decoded
                                  , startPositions = Data.Wec.Preprocess.Dict.startPositions_list decoded
                                  , ordersByLap = Data.Wec.Preprocess.Dict.ordersByLap_dict decoded
                                  }
                                )
                            )
                        |> List.map (\( size, options ) -> ( toString size, \_ -> Data.Wec.Preprocess.Dict.preprocessHelper options ))
                    )
                ]
        ]


replaceWithDict_preprocessHelper_benchmark_chart : List Content
replaceWithDict_preprocessHelper_benchmark_chart =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "測定結果：preprocessHelper"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24, CA.format formatWithCommas ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 16080582 }
                                , { x = 100, y = 15827913 }
                                , { x = 1000, y = 428 }
                                , { x = 2500, y = 428 }
                                , { x = 5000, y = 425 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 15880402 }
                                , { x = 100, y = 15428292 }
                                , { x = 1000, y = 423 }
                                , { x = 2500, y = 421 }
                                , { x = 5000, y = 420 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 16
                                , CA.format (\item -> CI.getData item |> .y |> formatWithCommas)
                                ]
                            ]
                    ]
        ]


improve_logic_overview : List Content
improve_logic_overview =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "概要"
        }
        [ markdownPage """
## 課題

- 不要な計算の繰り返し

## 改善の方針

- 計算の効率化
    - 中間結果の再利用
- アルゴリズムの改善
    - 計算量の削減
"""
        ]


improve_logic_code_old : List Content
improve_logic_code_old =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "実装の変更"
        }
        [ highlightElm identity """laps_old : { carNumber : String, laps : List Wec.Lap } -> List Lap
laps_old { carNumber, laps } =
    laps
        |> List.indexedMap
            (\\index { lapTime } ->
                { ...
                , best =
                    laps
                        |> List.take (index + 1)
                        |> List.map .lapTime
                        |> List.minimum
                        |> Maybe.withDefault 0
                }
            )"""
        ]


improve_logic_code : List Content
improve_logic_code =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "実装の変更"
        }
        [ highlightElm identity """laps_improved : { carNumber : String, laps : List WecLap } -> List Lap
laps_improved { carNumber, laps } =
    let
        step : Wec.Lap -> Acc -> Acc
        step { lapTime } acc =
            let
                bestLapTime =
                    List.minimum (lapTime :: acc.bestLapTime)
            in
            { bestLapTime = bestLapTime
            , laps = currentLap :: acc.laps
            }
    in
    laps
        |> List.foldl step initialAcc
        |> .laps
        |> List.reverse"""
        ]


improve_logic_laps_benchmark : List Content
improve_logic_laps_benchmark =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "ベンチマーク：laps_"
        }
        [ Custom.benchmark <|
            Benchmark.describe "laps_"
                [ Benchmark.scale "old"
                    ([ --  10 -- 45,435,160 runs/s (GoF: 99.39%)
                       100 -- 45,075,492 runs/s (GoF: 97.85%)

                     --  , 1000 -- 427 runs/s (GoF: 99.95%)
                     --  , 2500 -- 421 runs/s (GoF: 99.96%)
                     , 5000 -- 423 runs/s (GoF: 99.96%)
                     ]
                        |> List.map
                            (\size ->
                                ( size
                                , let
                                    decoded =
                                        Fixture.csvDecodedOfSize size
                                  in
                                  { carNumber = "15"
                                  , laps = List.filter (\{ carNumber } -> carNumber == "15") decoded
                                  , ordersByLap = Beginning.ordersByLap_list decoded
                                  }
                                )
                            )
                        |> List.map (\( size, options ) -> ( toString size, \_ -> Beginning.laps_ options ))
                    )
                , Benchmark.scale "improved"
                    ([ -- 10 -- 80,915,084 runs/s (GoF: 99.12%)
                       100 -- 81,502,573 runs/s (GoF: 99.71%)

                     --  , 1000 -- 3,182 runs/s (GoF: 99.71%)
                     --  , 2500 -- 3,156 runs/s (GoF: 99.92%)
                     , 5000 -- 3,133 runs/s (GoF: 99.98%)
                     ]
                        |> List.map
                            (\size ->
                                ( size
                                , let
                                    decoded =
                                        Fixture.csvDecodedOfSize size
                                  in
                                  { carNumber = "15"
                                  , laps = List.filter (\{ carNumber } -> carNumber == "15") decoded
                                  , ordersByLap = Beginning.ordersByLap_list decoded
                                  }
                                )
                            )
                        |> List.map (\( size, options ) -> ( toString size, \_ -> Data.Wec.Preprocess.laps_ options ))
                    )
                ]
        ]


improve_logic_laps_benchmark_chart : List Content
improve_logic_laps_benchmark_chart =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "測定結果：laps_"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24, CA.format formatWithCommas ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 45435160 }
                                , { x = 100, y = 45075492 }
                                , { x = 1000, y = 427 }
                                , { x = 2500, y = 421 }
                                , { x = 5000, y = 423 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 80915084 }
                                , { x = 100, y = 81502573 }
                                , { x = 1000, y = 3182 }
                                , { x = 2500, y = 3156 }
                                , { x = 5000, y = 3133 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 16
                                , CA.format (\item -> CI.getData item |> .y |> formatWithCommas)
                                ]
                            ]
                    ]
        ]


improve_logic_preprocessHelper_benchmark : List Content
improve_logic_preprocessHelper_benchmark =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "ベンチマーク：preprocessHelper"
        }
        [ Custom.benchmark <|
            Benchmark.describe "preprocessHelper"
                [ Benchmark.scale "old"
                    ([ -- 10 -- 16,690,851 runs/s (GoF: 99.35%)
                       100 -- 16,993,472 runs/s (GoF: 99.63%)

                     --  , 1000 -- 430 runs/s (GoF: 99.92%)
                     --  , 2500 -- 428 runs/s (GoF: 99.97%)
                     , 5000 -- 427 runs/s (GoF: 99.97%)
                     ]
                        |> List.map
                            (\size ->
                                ( size
                                , let
                                    decoded =
                                        Fixture.csvDecodedOfSize size
                                  in
                                  { carNumber = "15"
                                  , laps = List.filter (\{ carNumber } -> carNumber == "15") decoded
                                  , startPositions = Beginning.startPositions_list decoded
                                  , ordersByLap = Beginning.ordersByLap_list decoded
                                  }
                                )
                            )
                        |> List.map (\( size, options ) -> ( toString size, \_ -> Beginning.preprocessHelper options ))
                    )
                , Benchmark.scale "improved"
                    ([ --  10 -- 18,660,245 runs/s (GoF: 99.66%)
                       100 -- 18,822,823 runs/s (GoF: 99.73%)

                     --  , 1000 -- 3,132 runs/s (GoF: 99.73%)
                     --  , 2500 -- 3,096 runs/s (GoF: 99.88%)
                     , 5000 -- 3,091 runs/s (GoF: 99.96%)
                     ]
                        |> List.map
                            (\size ->
                                ( size
                                , let
                                    decoded =
                                        Fixture.csvDecodedOfSize size
                                  in
                                  { carNumber = "15"
                                  , laps = List.filter (\{ carNumber } -> carNumber == "15") decoded
                                  , startPositions = Beginning.startPositions_list decoded
                                  , ordersByLap = Beginning.ordersByLap_list decoded
                                  }
                                )
                            )
                        |> List.map (\( size, options ) -> ( toString size, \_ -> Data.Wec.Preprocess.preprocessHelper options ))
                    )
                ]
        ]


improve_logic_preprocessHelper_benchmark_chart : List Content
improve_logic_preprocessHelper_benchmark_chart =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "測定結果：preprocessHelper"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24, CA.format formatWithCommas ]
                            , C.yLabels
                                [ CA.withGrid
                                , CA.fontSize 24
                                , CA.format (\y -> formatWithCommas (exponential y))
                                ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 16690851 }
                                , { x = 100, y = 16993472 }
                                , { x = 1000, y = 430 }
                                , { x = 2500, y = 428 }
                                , { x = 5000, y = 427 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 18660245 }
                                , { x = 100, y = 18822823 }
                                , { x = 1000, y = 3132 }
                                , { x = 2500, y = 3096 }
                                , { x = 5000, y = 3091 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 16
                                , CA.format (\item -> CI.getData item |> .y |> formatWithCommas)
                                ]
                            ]
                    ]
        ]


improve_logic_benchmark : List Content
improve_logic_benchmark =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "ベンチマーク：preprocess"
        }
        [ Custom.benchmark <|
            Benchmark.describe "preprocess"
                [ Benchmark.scale "old"
                    ([ 10 -- 92,293 runs/s (GoF: 99.68%)
                     , 100 -- 1,665 runs/s (GoF: 99.55%)

                     --  , 1000 -- 70 runs/s (GoF: 99.99%)
                     --    2500 -- 26 runs/s (GoF: 99.99%)
                     --  , 5000 -- 13 runs/s (GoF: 99.99%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.preprocess target ))
                    )
                , Benchmark.scale "improved"
                    ([ 10 -- 109,789 runs/s (GoF: 99.85%)
                     , 100 -- 7,305 runs/s (GoF: 99.89%)

                     --   , 1000 -- 196 runs/s (GoF: 100%)
                     --    2500 -- 69 runs/s (GoF: 99.99%)
                     --  , 5000 -- 32 runs/s (GoF: 99.98%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Data.Wec.Preprocess.preprocess target ))
                    )
                ]
        ]


improve_logic_benchmark_chart : List Content
improve_logic_benchmark_chart =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "測定結果：preprocess"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24 ]
                            , C.yLabels [ CA.withGrid, CA.fontSize 24, CA.format (\y -> formatWithCommas (exponential y)) ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データサイズ" ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#d32f2f" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 92293 }
                                , { x = 100, y = 1665 }
                                , { x = 1000, y = 70 }
                                , { x = 2500, y = 26 }
                                , { x = 5000, y = 13 }
                                ]
                            , C.series .x
                                [ C.interpolated (.y >> logarithmic) [ CA.color "#388e3c" ] [ CA.circle, CA.size 40 ] ]
                                [ { x = 10, y = 109789 }
                                , { x = 100, y = 7305 }
                                , { x = 1000, y = 196 }
                                , { x = 2500, y = 69 }
                                , { x = 5000, y = 32 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 18
                                , CA.format
                                    (\item ->
                                        let
                                            data =
                                                CI.getData item
                                        in
                                        formatWithCommas data.y
                                    )
                                ]
                            ]
                    ]
        ]


replaceWithJson_overview : List Content
replaceWithJson_overview =
    page
        { chapter = "改善④ 入力データ形式の変更"
        , title = "CSVからJSONへの移行"
        }
        [ markdownPage """
- CSVとJSONの処理特性の違い
- JSONデコードに変更した実装
- パフォーマンスへの影響
"""
        , highlightElm identity """import Json.Decode as Decode

jsonDecoder : Decode.Decoder CsvData
jsonDecoder =
    Decode.map3 CsvData
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "value" Decode.float)

processJsonData : String -> Result Decode.Error (List CsvData)
processJsonData json =
    Decode.decodeString (Decode.list jsonDecoder) json"""
        ]


replaceWithJson_benchmark : List Content
replaceWithJson_benchmark =
    page
        { chapter = "改善④ 入力データ形式の変更"
        , title = "ベンチマーク：decodedr"
        }
        [ Custom.benchmark <|
            Benchmark.compare "decodedr"
                "csvDecoded"
                -- 307 runs/s (GoF: 99.99%) ※426件のデータで実施
                -- 24 runs/s (GoF: 99.99%)
                (\_ ->
                    case CD.decodeCustom { fieldSeparator = ';' } FieldNamesFromFirstRow Wec.lapDecoder Fixture.csv of
                        Ok decoded_ ->
                            decoded_

                        Err _ ->
                            []
                )
                "jsonDecoded"
                -- 799 runs/s (GoF: 100%) ※426件のデータで実施
                -- 62 runs/s (GoF: 99.99%)
                (\_ ->
                    case JD.decodeString (JD.field "laps" (JD.list Data.Wec.lapDecoder)) Fixture.json of
                        Ok decoded_ ->
                            decoded_

                        Err _ ->
                            []
                )
        ]


replaceWithJson_benchmark_chart : List Content
replaceWithJson_benchmark_chart =
    page
        { chapter = "改善④ 入力データ形式の変更"
        , title = "測定結果：CSV vs JSON"
        }
        [ item <|
            Html.toUnstyled <|
                div
                    [ css
                        [ width (px 800)
                        , height (px 500)
                        , margin2 zero auto
                        ]
                    ]
                    [ Html.fromUnstyled <|
                        C.chart
                            [ CA.height 500
                            , CA.width 800
                            , CA.margin { top = 20, right = 20, bottom = 60, left = 80 }
                            ]
                            [ C.xLabels [ CA.withGrid, CA.fontSize 24 ]
                            , C.yLabels [ CA.withGrid, CA.fontSize 24 ]
                            , C.labelAt .min CA.middle [ CA.fontSize 20, CA.moveLeft 100, CA.rotate 90 ] [ Svg.text "実行回数/秒" ]
                            , C.labelAt CA.middle .min [ CA.fontSize 20, CA.moveDown 80 ] [ Svg.text "データ形式" ]
                            , C.series .x
                                [ C.interpolated .y [ CA.color "#d32f2f" ] [ CA.circle, CA.size 100 ] ]
                                [ { x = 1, y = 307 }
                                ]
                            , C.series .x
                                [ C.interpolated .y [ CA.color "#388e3c" ] [ CA.circle, CA.size 100 ] ]
                                [ { x = 1, y = 799 }
                                ]
                            , C.dotLabels
                                [ CA.moveUp 20
                                , CA.fontSize 18
                                , CA.format
                                    (\item ->
                                        let
                                            data =
                                                CI.getData item
                                        in
                                        formatWithCommas data.y
                                    )
                                ]
                            ]
                    ]
        ]


cli : List Content
cli =
    page
        { chapter = "改善⑤ その他の選択肢"
        , title = ""
        }
        [ markdownPage """
## ElmにはUIのないヘッドレスプログラムを作成する機能がある

- CLIアプリケーションを作ることが可能
- 既存のElmのアプリケーションコードを転用できる
- デコードや前処理を実行済みのJSONを出力し、それを読み込むことにした
    - ボトルネック解消！！！

## Html.Lazy や Html.Keyed の活用

- もしボトルネックがViewの再描画にある場合は、これらの関数を活用することで改善できる
"""
        ]


lessonsLearned : List Content
lessonsLearned =
    page
        { chapter = "ベンチマークから得られた知見"
        , title = "データ構造・パフォーマンス・実務応用"
        }
        [ markdownPage """
## パフォーマンス最適化の原則

- **測定してから最適化**: 推測より実測が重要
- **段階的改善**: 小さな変更を積み重ねて効果を確認
- **適切なデータ構造の選択**: List、Array、Dictの使い分け

## 実装から得た教訓

- **実測の価値**: ベンチマークで予想外の結果を発見
- **シンプルさの力**: 理解しやすい実装の重要性
- **プラットフォーム理解**: ElmとJavaScript VMの特性把握

## The Elm Architectureでの最適化

- Html.Lazy, Html.Keyed の活用
- モデル設計の見直し
- データ構造の選択

## 自作実装の価値

- **教育効果**: 内部動作の深い理解
- **カスタマイズ性**: 特定用途への最適化
- **学習機会**: 関数型プログラミングの実践
"""
        ]


conclusion : List Content
conclusion =
    [ background "assets/images/cover_20231202.jpg"
        (markdown """
# まとめ

## 主な成果

- **Array専用ソート**: List型を使わない完全なArray実装を実現
- **複数アルゴリズム検証**: ヒープソート、マージソート、クイックソートを比較
- **実測による発見**: 理論と実践の違いを体験

## 効果的な最適化アプローチ

- 段階的な改善: List → Array → Dict → ロジック改善
- 測定主導の開発: ベンチマークで効果を確認
- シンプルさの価値: 可読性とパフォーマンスのバランス

## 今後の展望

- より大規模データでの検証
- WebWorkersやWebAssemblyとの比較
- 実用アプリケーションでの活用

[サンプルコードとベンチマーク結果](https://github.com/y047aka/elm-benchmark-example)
""")
    ]
