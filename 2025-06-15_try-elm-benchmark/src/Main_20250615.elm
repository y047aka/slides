module Main_20250615 exposing (main)

import Array exposing (Array)
import Array.Extra2
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
import Formatting.Styled as Formatting exposing (background, colored, highlightElm, markdown, markdownPage, page, spacer)
import Html.Styled as Html exposing (br, div, h1, img, span, text)
import Html.Styled.Attributes exposing (css, src)
import Json.Decode as JD
import MyBenchmark as Benchmark
import SliceShow exposing (Message, Model, init, setSubscriptions, setUpdate, setView, show)
import SliceShow.Slide exposing (setDimensions, slide)


main : Program () (Model Custom.Model Msg) (Message Msg)
main =
    slides
        |> List.map (slide >> setDimensions ( 1280, 720 ))
        |> init
        |> setSubscriptions Custom.subscriptions
        |> setView Custom.view
        |> setUpdate Custom.update
        |> show


slides : List (List Content)
slides =
    List.concat
        [ [ cover

          -- はじめに
          , introduction
          , elmIntro
          , motivation
          , benchmark_basics
          , benchmark_considerations
          ]
        , chapter "elm-explorations/benchmark"
            "P1001668.jpeg"
            [ elmBenchmark_overview
            , elmBenchmark_example
            , elmBenchmark_benchmark
            ]
        , chapter "elm-motorsport-analysis"
            "elm_motorsport_analysis.png"
            [ sampleData
            , oldCode_workflow
            , oldCode_benchmark
            ]
        , chapter "パフォーマンス改善の計画"
            "P1001938.jpeg"
            [ optimization_ideas ]
        , chapter "改善① List を Array に置き換える"
            "P1002085.jpeg"
            [ replaceWithArray_overview
            , replaceWithArray_study
            , replaceWithArray_code
            , replaceWithArray_benchmark
            , replaceWithArray_sortBy
            , replaceWithArray_sortBy_benchmark
            ]
        , chapter "改善② AssocList を Dict に置き換える"
            "P1002442.jpeg"
            [ replaceWithDict_overview
            , replaceWithDict_code
            , replaceWithDict_ordersByLap_benchmark
            , replaceWithDict_preprocessHelper_benchmark
            ]
        , chapter "改善③ 計算ロジックを改良する"
            "P1002755.jpeg"
            [ improve_logic_overview
            , improve_logic_code_old
            , improve_logic_code
            , improve_logic_laps_benchmark
            , improve_logic_preprocessHelper_benchmark
            , improve_logic_benchmark
            ]
        , chapter "改善④ 入力データ形式の変更"
            "P1003304.jpeg"
            [ replaceWithJson_overview
            , replaceWithJson_benchmark
            ]
        , chapter "改善⑤ その他の選択肢"
            "P1002574.jpeg"
            [ cli ]
        , chapter "ベンチマークから得られた知見"
            ""
            [ lessonsLearned ]
        , [ conclusion ]
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
- Elmの簡単な紹介
- ベンチマーク測定方法の説明
- 最適化の試み
    - List を Array に置き換える
    - AssocList を Dict に置き換える
    - 計算ロジックを改良する
    - 入力データ形式の変更
"""
        ]


elmIntro : List Content
elmIntro =
    page
        { chapter = "はじめに"
        , title = "Elm の紹介"
        }
        [ markdownPage """
Elm はフロントエンド開発向けの純粋関数型言語です

- JavaScriptにコンパイルされる
- 型安全性が高く、Webアプリを安全に構築できる
- The Elm Architecture（TEA）による宣言的なUI設計
- HaskellやOCamlなどの影響を受けつつ、シンプルな文法で学びやすい
- 親切なエラーメッセージで開発体験が良い
"""
        ]


motivation : List Content
motivation =
    page
        { chapter = "はじめに"
        , title = "今回の動機"
        }
        [ markdownPage """
好奇心：ベンチマークテストを体験してみたい

- `List` と `Array` のパフォーマンスの違いを体感する
- 非効率なコードが残っているうちに試したい
    - 改善の幅が大きいほうが楽しい
    - アプリケーションの機能追加を予定していたので、その前に挑戦したい
"""
        ]


benchmark_basics : List Content
benchmark_basics =
    page
        { chapter = "はじめに"
        , title = "ベンチマークテストの概要"
        }
        [ markdownPage """
## ベンチマークテストの目的

- システムの性能を評価する
- 異なる実装アプローチでの性能を比較する
- ボトルネックを特定する

## いつベンチマークを測定する？

- パフォーマンスの問題が発生したとき
"""
        ]


benchmark_considerations : List Content
benchmark_considerations =
    page
        { chapter = "はじめに"
        , title = "ベンチマーク測定時の注意点"
        }
        [ markdownPage """
## 測定環境の統一

- CPU、メモリ、ネットワーク環境などの条件を揃える
- バックグラウンドプロセスの影響を最小化

## 統計的な有意性

- 十分なサンプル数の確保、外れ値の除外

## 測定の再現性

- 同じ条件での再測定すれば、同じ結果が得られるように
"""
        ]


elmBenchmark_overview : List Content
elmBenchmark_overview =
    page
        { chapter = "elm-explorations/benchmark"
        , title = "Elmコードのベンチマークを実行するためのパッケージ"
        }
        [ markdownPage """
## 測定環境の統一

- 測定前にJITコンパイルを強制する（Warming JIT）

## 統計的な有意性

- 有意な結果を得るまで反復実行（Collecting Samples）
    - 複数対象を交互に実行し、測定の偏りを軽減する
- 測定結果の信頼性を評価する指標（Goodness of Fit）
    - （99%: 優秀 / 95%: 良好 / 90%: 要注意 / 80%以下: 信頼性低）
"""
        ]


elmBenchmark_example : List Content
elmBenchmark_example =
    page
        { chapter = "elm-explorations/benchmark"
        , title = "使用例"
        }
        [ highlightElm """import Benchmark exposing (..)

suite : Benchmark
suite =
    describe "FizzBuzz"
        [ benchmark "fizzBuzz" <|
            \\_ -> fizzBuzz 100
        ]

fizzBuzz : Int -> String
fizzBuzz n =
    case ( modBy 3 n, modBy 5 n ) of
        ( 0, 0 ) -> "FizzBuzz"

        ( 0, _ ) -> "Fizz"

        ( _, 0 ) -> "Buzz"

        _ -> String.fromInt n"""
        ]


elmBenchmark_benchmark : List Content
elmBenchmark_benchmark =
    page
        { chapter = "elm-explorations/benchmark"
        , title = "ベンチマーク測定の様子"
        }
        [ Custom.benchmark <|
            Benchmark.describe "fizzBuzz"
                [ Benchmark.benchmark "from the beginning" <|
                    \_ -> fizzBuzz 100
                ]
        ]


fizzBuzz : Int -> String
fizzBuzz n =
    case ( modBy 3 n, modBy 5 n ) of
        ( 0, 0 ) ->
            "FizzBuzz"

        ( 0, _ ) ->
            "Fizz"

        ( _, 0 ) ->
            "Buzz"

        _ ->
            String.fromInt n


sampleData : List Content
sampleData =
    page
        { chapter = "elm-motorsport-analysis"
        , title = "ル・マン24時間レース（2024年）の走行データ"
        }
        [ highlightElm """NUMBER; DRIVER_NUMBER; LAP_NUMBER; LAP_TIME; LAP_IMPROVEMENT; CROSSING_FINISH_LINE_IN_PIT; S1; S1_IMPROVEMENT; S2; S2_IMPROVEMENT; S3; S3_IMPROVEMENT; KPH; ELAPSED; HOUR;S1_LARGE;S2_LARGE;S3_LARGE;TOP_SPEED;DRIVER_NAME;PIT_TIME;CLASS;GROUP;TEAM;MANUFACTURER;FLAG_AT_FL;S1_SECONDS;S2_SECONDS;S3_SECONDS;
10;2;1;3:53.276;0;;45.985;0;1:26.214;0;1:41.077;0;208.1;3:53.276;16:04:19.878;0:45.985;1:26.214;1:41.077;316.3;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;45.985;86.214;101.077;
10;2;2;3:39.529;0;;34.734;0;1:24.901;0;1:39.894;0;223.4;7:32.805;16:07:59.407;0:34.734;1:24.901;1:39.894;315.4;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;34.734;84.901;99.894;
10;2;3;3:39.240;2;;34.715;0;1:24.814;0;1:39.711;0;223.7;11:12.045;16:11:38.647;0:34.715;1:24.814;1:39.711;313.6;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;34.715;84.814;99.711;
10;2;4;3:39.458;0;;34.774;0;1:24.878;0;1:39.806;0;223.5;14:51.503;16:15:18.105;0:34.774;1:24.878;1:39.806;313.6;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;34.774;84.878;99.806;
10;2;5;3:39.364;0;;34.676;0;1:24.777;0;1:39.911;0;223.6;18:30.867;16:18:57.469;0:34.676;1:24.777;1:39.911;314.5;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;34.676;84.777;99.911;
10;2;6;3:40.955;0;;35.178;0;1:25.610;0;1:40.167;0;222.0;22:11.822;16:22:38.424;0:35.178;1:25.610;1:40.167;312.7;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;35.178;85.610;100.167;
10;2;7;3:40.463;0;;34.798;0;1:24.912;0;1:40.753;0;222.5;25:52.285;16:26:18.887;0:34.798;1:24.912;1:40.753;315.4;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;34.798;84.912;100.753;
10;2;8;3:40.552;0;;35.068;0;1:24.982;0;1:40.502;0;222.4;29:32.837;16:29:59.439;0:35.068;1:24.982;1:40.502;313.6;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;35.068;84.982;100.502;
10;2;9;3:46.324;0;B;34.905;0;1:24.760;0;1:46.659;0;216.7;33:19.161;16:33:45.763;0:34.905;1:24.760;1:46.659;313.6;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;34.905;84.760;106.659;
10;2;10;4:58.334;0;;1:51.808;0;1:25.765;0;1:40.761;0;164.4;38:17.495;16:38:44.097;1:51.808;1:25.765;1:40.761;309.1;Patrick PILET;0:01:27.261;LMP2;;Vector Sport;Oreca;GF;111.808;85.765;100.761;
10;2;11;3:43.277;0;;36.637;0;1:25.990;0;1:40.650;0;219.7;42:00.772;16:42:27.374;0:36.637;1:25.990;1:40.650;310.9;Patrick PILET;;LMP2;;Vector Sport;Oreca;GF;36.637;85.990;100.650;
…
99;2;251;4:07.503;0;;40.250;0;1:31.114;0;1:56.139;0;198.2;24:05:35.985;16:06:02.587;0:40.250;1:31.114;1:56.139;242.0;Harry TINCKNELL;;HYPERCAR;H;Proton Competition;Porsche;FF;40.250;91.114;116.139;"""
        ]


oldCode_workflow : List Content
oldCode_workflow =
    page
        { chapter = "elm-motorsport-analysis"
        , title = "CSVをパースし、周回データとしてデコード"
        }
        [ markdownPage """
- 周回データを解析し、車両単位で再構成
"""
        , highlightElm """preprocess : List Lap -> List Car
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


oldCode_benchmark : List Content
oldCode_benchmark =
    page
        { chapter = "elm-motorsport-analysis"
        , title = "ベンチマーク"
        }
        [ Custom.benchmark <|
            Benchmark.describe "Data.Wec.Preprocess"
                [ Benchmark.scale "old"
                    ([ 10 -- 67,307 runs/s (GoF: 99.99%)
                     , 100 -- 1,272 runs/s (GoF: 99.99%)

                     --  , 1000 -- 62 runs/s (GoF: 99.99%)
                     --  , 5000 -- 11 runs/s (GoF: 100%)
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


optimization_ideas : List Content
optimization_ideas =
    page
        { chapter = "パフォーマンス改善の計画"
        , title = "改善のアイデア"
        }
        [ markdownPage """
- `List` を `Array` に置き換える
    - 1万行以上のデータを扱うので、Arrayの優位性を体感できそう？
- `AssocList` を `Dict` に置き換える
- 計算ロジックの見直し
- CSVのデコードパッケージを自作する
    - `Array` を前提とした実装に変更すれば速くなるかな？
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
        , highlightElm """{-| スタート時の各車両の順位を求める関数
    暫定的に1周目の通過タイムの早かった順で代用している
-}
startPositions : List Lap -> List String
startPositions laps =
    List.filter (\\{ lapNumber } -> lapNumber == 1) laps
        |> List.sortBy .elapsed
        |> List.map .carNumber"""
        ]


replaceWithArray_study : List Content
replaceWithArray_study =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "List.length と Array.length の比較"
        }
        [ Custom.benchmark <|
            Benchmark.describe "length" <|
                [ Benchmark.scale "List.length"
                    ([ 5 -- 30,822,646 runs/s (GoF: 99.9%)
                     , 50 -- 3,824,299 runs/s (GoF: 99.9%)
                     , 500 -- 392,379 runs/s (GoF: 99.92%)

                     --  , 5000 -- 38,310 runs/s (GoF: 99.79%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> List.length target ))
                    )
                , Benchmark.scale "Array.length"
                    ([ 5 -- 274,508,871 runs/s (GoF: 99.61%)
                     , 50
                     , 500

                     --  , 5000 -- 274,955,086 runs/s (GoF: 99.67%)
                     ]
                        |> List.map (\size -> ( size, Array.fromList (Fixture.csvDecodedOfSize size) ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Array.length target ))
                    )
                ]
        ]


toString : Int -> String
toString n =
    "n = " ++ String.fromInt n


replaceWithArray_code : List Content
replaceWithArray_code =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "実装の変更"
        }
        [ highlightElm """{-| スタート時の各車両の順位を求める関数
    暫定的に1周目の通過タイムの早かった順で代用している
-}
startPositions : Array Wec.Lap -> List String
startPositions laps =
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
                [ Benchmark.scale "List"
                    ([ 5 -- 10,777,648 runs/s (GoF: 99.95%)
                     , 50 -- 2,137,145 runs/s (GoF: 99.93%)
                     , 500 -- 206,667 runs/s (GoF: 99.84%)
                     , 5000 -- 21,238 runs/s (GoF: 99.85%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.startPositions_list target ))
                    )
                , Benchmark.scale " Listに変換して List.sortBy"
                    ([ 5 -- 3,936,471 runs/s (GoF: 99.95%)
                     , 50 -- 1,500,727 runs/s (GoF: 99.97%)
                     , 500 -- 230,693 runs/s (GoF: 99.96%)
                     , 5000 -- 22,697 runs/s (GoF: 99.96%)
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

- マージソートによる `Array.Extra2.sortBy` 関数を試作した
- List.sortByと同等のパフォーマンスは得られたものの、`List` に変換してソートするほうが早いという結果になった
"""
        ]


replaceWithArray_sortBy_benchmark : List Content
replaceWithArray_sortBy_benchmark =
    page
        { chapter = "改善① List を Array に置き換える"
        , title = "ベンチマーク：startPositions"
        }
        [ Custom.benchmark <|
            Benchmark.describe "startPositions"
                [ Benchmark.scale "Listに変換して List.sortBy"
                    ([ 5 -- 3,936,471 runs/s (GoF: 99.95%)
                     , 50 -- 1,500,727 runs/s (GoF: 99.97%)
                     , 500 -- 230,693 runs/s (GoF: 99.96%)
                     , 5000 -- 22,697 runs/s (GoF: 99.96%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size |> Array.fromList ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> startPositions_tmp target ))
                    )
                , Benchmark.scale "Array.Extra2.sortBy"
                    ([ 5 -- 3,936,471 runs/s (GoF: 99.95%)
                     , 50 -- 1,500,727 runs/s (GoF: 99.97%)
                     , 500 -- 230,693 runs/s (GoF: 99.96%)
                     , 5000 -- 22,697 runs/s (GoF: 99.96%)
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


replaceWithDict_overview : List Content
replaceWithDict_overview =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "概要"
        }
        [ markdownPage """
- AssocListを使用しているため、検索に線形時間（O(n)）が必要
    - データ量が増えると処理時間が比例して増加してしまう
- Dictを使用して検索を定数時間（O(1)）に改善したい
<br />

| | AssocList | Dict |
| --- | --- | --- |
| 実装 | キーと値のペアをリストで管理<br />（任意の型をキーにできる） | ハッシュベースの実装                   |
| 検索速度 | （O(n)）<br />線形検索が必要 | （O(1)）<br />定数時間でのアクセスが可能 |
| メモリ使用量 | 少ない | 多い |
"""
        ]


replaceWithDict_code : List Content
replaceWithDict_code =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "実装の変更"
        }
        [ highlightElm """{-| 各周回での各車両の順位を求める関数
-}
ordersByLap_dict : List Wec.Lap -> OrdersByLap
ordersByLap_dict laps =
    laps
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
                    ([ 5 -- 1,290,015 runs/s (GoF: 99.97%)
                     , 50 -- 71,653 runs/s (GoF: 99.98%)
                     , 500 -- 625 runs/s (GoF: 99.99%)

                     --  , 5000 -- 46 runs/s (GoF: 99.97%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.ordersByLap_list target ))
                    )
                , Benchmark.scale "Dict"
                    ([ 5 -- 945,315 runs/s (GoF: 99.99%)
                     , 50 -- 64,006 runs/s (GoF: 99.98%)
                     , 500 -- 5,279 runs/s (GoF: 99.99%)

                     --  , 5000 -- 541 runs/s (GoF: 99.99%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Data.Wec.Preprocess.Dict.ordersByLap_dict target ))
                    )
                ]
        ]


replaceWithDict_preprocessHelper_benchmark : List Content
replaceWithDict_preprocessHelper_benchmark =
    page
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "ベンチマーク：preprocessHelper"
        }
        [ Custom.benchmark <|
            let
                options_beginning =
                    { carNumber = "15"
                    , laps = Fixture.csvDecodedForCarNumber "15"
                    , startPositions = Beginning.startPositions_list Fixture.csvDecoded
                    , ordersByLap = Beginning.ordersByLap_list Fixture.csvDecoded
                    }

                options_dict =
                    { carNumber = "15"
                    , laps = Fixture.csvDecodedForCarNumber "15"
                    , startPositions = Data.Wec.Preprocess.Dict.startPositions_list Fixture.csvDecoded
                    , ordersByLap = Data.Wec.Preprocess.Dict.ordersByLap_dict Fixture.csvDecoded
                    }
            in
            Benchmark.compare "preprocessHelper"
                "old"
                -- 349 runs/s (GoF: 99.99%)
                (\_ -> Beginning.preprocessHelper options_beginning)
                "improved"
                -- 2,215 runs/s (GoF: 99.95%)
                (\_ -> Data.Wec.Preprocess.Dict.preprocessHelper options_dict)
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
        [ highlightElm """laps_old : { carNumber : String, laps : List Wec.Lap } -> List Lap
laps_old { carNumber, laps } =
    laps
        |> List.indexedMap
            (\\index { s1, s2, s3 } ->
                { ...
                , s1_best =
                    laps
                        |> List.take (index + 1)
                        |> List.filterMap .s1
                        |> List.minimum
                        |> Maybe.withDefault 0
                , s2_best =
                    laps
                        |> List.take (index + 1)
                        |> List.filterMap .s2
                        |> List.minimum
                        |> Maybe.withDefault 0
                , s3_best =
                    laps
                        |> List.take (index + 1)
                        |> List.filterMap .s3
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
        [ highlightElm """laps_improved : { carNumber : String, laps : List Wec.Lap } -> List Lap
laps_improved { carNumber, laps } =
    let
        step : Wec.Lap -> Acc -> Acc
        step { s1, s2, s3 } acc =
            let
                ( bestS1, bestS2, bestS3 ) =
                    ( List.minimum (List.filterMap identity [ s1, acc.bestS1 ])
                    , List.minimum (List.filterMap identity [ s2, acc.bestS2 ])
                    , List.minimum (List.filterMap identity [ s3, acc.bestS3 ])
                    )

                currentLap =
                    ...
            in
            { bestS1 = bestS1
            , bestS2 = bestS2
            , bestS3 = bestS3
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
            let
                options =
                    { carNumber = "15"
                    , laps = Fixture.csvDecodedForCarNumber "15"
                    , ordersByLap = Beginning.ordersByLap_list Fixture.csvDecoded
                    }
            in
            Benchmark.compare "laps_"
                "old"
                -- 294 runs/s (GoF: 99.99%)
                (\_ -> Beginning.laps_ options)
                "improved"
                -- 2,199 runs/s (GoF: 99.96%)
                (\_ -> Data.Wec.Preprocess.laps_ options)
        ]


improve_logic_preprocessHelper_benchmark : List Content
improve_logic_preprocessHelper_benchmark =
    page
        { chapter = "改善③ 計算ロジックを改良する"
        , title = "ベンチマーク：preprocessHelper"
        }
        [ Custom.benchmark <|
            let
                options =
                    { carNumber = "15"
                    , laps = Fixture.csvDecodedForCarNumber "15"
                    , startPositions = Beginning.startPositions_list Fixture.csvDecoded
                    , ordersByLap = Beginning.ordersByLap_list Fixture.csvDecoded
                    }
            in
            Benchmark.compare "preprocessHelper"
                "old"
                -- 349 runs/s (GoF: 99.99%)
                (\_ -> Beginning.preprocessHelper options)
                "improved"
                -- 2,215 runs/s (GoF: 99.95%)
                (\_ -> Data.Wec.Preprocess.preprocessHelper options)
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
                    ([ 10 -- 67,307 runs/s (GoF: 99.99%)
                     , 100 -- 1,272 runs/s (GoF: 99.99%)

                     --  , 1000 -- 62 runs/s (GoF: 99.99%)
                     --  , 5000 -- 11 runs/s (GoF: 100%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.preprocess target ))
                    )
                , Benchmark.scale "improved"
                    ([ 10 -- 117,702 runs/s (GoF: 99.99%)
                     , 100 -- 5,654 runs/s (GoF: 99.98%)

                     --  , 1000 -- 167 runs/s (GoF: 99.99%)
                     --  , 5000 -- 27 runs/s (GoF: 100%)
                     ]
                        |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                        |> List.map (\( size, target ) -> ( toString size, \_ -> Data.Wec.Preprocess.preprocess target ))
                    )
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
        , highlightElm """import Json.Decode as Decode

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
