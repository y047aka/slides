module Main_20250615 exposing (main)

import Array exposing (Array)
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
import Formatting.Styled as Formatting exposing (background, colored, highlightCode, highlightElm, markdown, markdownPage, pageHeader, spacer)
import Html.Styled as Html exposing (br, h1, img, span, text)
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
    [ cover

    -- はじめに
    , introduction
    , motivation
    , benchmark_basics
    , benchmark_considerations

    -- elm-explorations/benchmark
    , elmBenchmark_overview
    , elmBenchmark_example
    , elmBenchmark_benchmark
    , sampleData

    -- 最初の実装
    , oldCode_workflow
    , oldCode_benchmark

    -- 検証用サンプルデータ
    , optimization_ideas

    -- 改善① List を Array に置き換える
    , replaceWithArray_overview
    , replaceWithArray_study
    , replaceWithArray_code
    , replaceWithArray_benchmark
    , replaceWithArray_result

    -- 改善② AssocList を Dict に置き換える
    , replaceWithDict_overview
    , replaceWithDict_comparison
    , replaceWithDict_ordersByLap_benchmark
    , replaceWithDict_preprocess_benchmark

    -- 改善③：計算ロジックを改良する
    , improve_logic_overview
    , improve_logic_laps_benchmark
    , improve_logic_preprocess_benchmark
    , improve_logic_benchmark

    -- 改善④：入力データ形式の変更
    , replaceWithJson_overview
    , replaceWithJson_benchmark

    -- ベンチマークから得られた知見
    , lessonsLearned
    , realWorldApplications

    -- まとめ
    , conclusion
    ]


cover : List Content
cover =
    [ colored
        "hsl(200, 100%, 40%)"
        "#FFF"
        [ h1 []
            [ span
                [ css [ fontSize (rem 5) ] ]
                [ text "Elmのパフォーマンス、実際どうなの？" ]
            , br [] []
            , span [ css [ fontSize (rem 14) ] ] [ text "ベンチマークに入門してみた" ]
            ]
        , spacer 50
        , img
            [ src "assets/images/y047aka.png"
            , css
                [ width (px 75)
                , borderRadius (pct 50)
                ]
            ]
            []
        , span
            [ css
                [ position relative
                , top (rem -2)
                , paddingLeft (em 0.5)
                , fontSize (rem 4.5)
                ]
            ]
            [ text "Yoshitaka Totsuka" ]
        , spacer 20
        , text "関数型まつり2025"
        , spacer 10
        , text "2025-06-14"
        ]
    ]


introduction : List Content
introduction =
    [ pageHeader
        { chapter = "はじめに"
        , title = "発表の流れ"
        }
    , markdownPage """
- Elmの簡単な紹介
- ベンチマーク測定方法の説明
- 最適化の試み
    - List を Array に置き換える
    - AssocList を Dict に置き換える
    - 計算ロジックを改良する
    - 入力データ形式の変更
"""
    ]


motivation : List Content
motivation =
    [ pageHeader
        { chapter = "はじめに"
        , title = "今回の動機"
        }
    , markdownPage """
- 好奇心：ベンチマークテストを体験してみたい
    - `List` と `Array` のパフォーマンスの違いを体感する
    - 非効率なコードが残っているうちに試したい
        - 改善の幅が大きいほうが楽しい
        - アプリケーションの機能追加を予定していたので、その前に挑戦したい
"""
    ]


benchmark_basics : List Content
benchmark_basics =
    [ pageHeader
        { chapter = "はじめに"
        , title = "ベンチマークテストの概要"
        }
    , markdownPage """
- ベンチマークテストの目的
    - システムの性能を評価する
    - 異なる実装アプローチでの性能を比較する
    - ボトルネックを特定する
- いつベンチマークを測定する？
    - パフォーマンスの問題が発生したとき
"""
    ]


benchmark_considerations : List Content
benchmark_considerations =
    [ pageHeader
        { chapter = "はじめに"
        , title = "ベンチマーク測定時の注意点"
        }
    , markdownPage """
- 測定環境の統一
    - CPU、メモリ、ネットワーク環境などの条件を揃える
    - バックグラウンドプロセスの影響を最小化
- 統計的な有意性
    - 十分なサンプル数の確保、外れ値の除外
- 測定の再現性
    - 同じ条件での再測定すれば、同じ結果が得られるように
"""
    ]


elmBenchmark_overview : List Content
elmBenchmark_overview =
    [ pageHeader
        { chapter = "elm-explorations/benchmark"
        , title = "Elmコードのベンチマークを実行するためのパッケージ"
        }
    , markdownPage """
- 測定環境の統一
    - 測定前にJITコンパイルを強制する（Warming JIT）
- 統計的な有意性
    - 有意な結果を得るまで反復実行（Collecting Samples）
        - 複数対象を交互に実行し、測定の偏りを軽減する
    - 測定結果の信頼性を評価する指標（Goodness of Fit）
        - （99%: 優秀 / 95%: 良好 / 90%: 要注意 / 80%以下: 信頼性低）
"""
    ]


elmBenchmark_example : List Content
elmBenchmark_example =
    [ pageHeader
        { chapter = "elm-explorations/benchmark"
        , title = "使用例"
        }
    , highlightElm """import Benchmark exposing (..)

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

        _ -> String.fromInt n
"""
    ]


elmBenchmark_benchmark : List Content
elmBenchmark_benchmark =
    [ pageHeader
        { chapter = "elm-explorations/benchmark"
        , title = "ベンチマーク測定の様子"
        }
    , Custom.benchmark <|
        Benchmark.describe "FizzBuzz"
            [ Benchmark.describe "fizzBuzz"
                [ Benchmark.benchmark "from the beginning" <|
                    \_ -> fizzBuzz 100
                , Benchmark.benchmark "from the end" <|
                    \_ -> fizzBuzz 1000
                ]
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
    [ pageHeader
        { chapter = "検証用サンプルデータ"
        , title = "ル・マン24時間レース（2024年）の走行データ"
        }
    , highlightCode """NUMBER; DRIVER_NUMBER; LAP_NUMBER; LAP_TIME; LAP_IMPROVEMENT; CROSSING_FINISH_LINE_IN_PIT; S1; S1_IMPROVEMENT; S2; S2_IMPROVEMENT; S3; S3_IMPROVEMENT; KPH; ELAPSED; HOUR;S1_LARGE;S2_LARGE;S3_LARGE;TOP_SPEED;DRIVER_NAME;PIT_TIME;CLASS;GROUP;TEAM;MANUFACTURER;FLAG_AT_FL;S1_SECONDS;S2_SECONDS;S3_SECONDS;
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
    [ pageHeader
        { chapter = "最初の実装"
        , title = "CSVをパースし、周回データとしてデコード"
        }
    , markdownPage """
- 周回データを解析し、車両単位で再構成
"""
    , highlightElm """preprocess : List Lap -> List Car
preprocess laps =
    laps
        |> AssocList.Extra.groupBy .carNumber
        |> AssocList.toList
        |> List.map
            (\\( carNumber, laps_ ) ->
                preprocess_old
                    { carNumber = carNumber
                    , laps = ...
                    , startPositions = ...
                    , ordersByLap = ...
                    }
            )"""
    ]


oldCode_benchmark : List Content
oldCode_benchmark =
    [ pageHeader
        { chapter = "最初の実装"
        , title = "ベンチマーク"
        }
    , Custom.benchmark <|
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
              Benchmark.benchmark "preprocess_"
                (\_ ->
                    -- 375 runs/s (GoF: 100%)
                    Beginning.preprocess_ options
                )
            ]
    ]


optimization_ideas : List Content
optimization_ideas =
    [ pageHeader
        { chapter = "パフォーマンス改善の計画"
        , title = "改善のアイデア"
        }
    , markdownPage """
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
    [ pageHeader
        { chapter = "改善① List を Array に置き換える"
        , title = "概要"
        }
    , markdownPage """
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


{-| <https://github.com/y047aka/elm-motorsport-analysis/pull/4/commits/98e10ec08c46a0aa6549fe01bbf41d9125387dbc>
-}
replaceWithArray_study : List Content
replaceWithArray_study =
    [ pageHeader
        { chapter = "改善① List を Array に置き換える"
        , title = "List.length と Array.length の比較"
        }
    , Custom.benchmark <|
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
                 , 5000 -- 274,955,086 runs/s (GoF: 99.67%)
                 ]
                    |> List.map (\size -> ( size, Array.fromList (Fixture.csvDecodedOfSize size) ))
                    |> List.map (\( size, target ) -> ( toString size, \_ -> Array.length target ))
                )
            , Benchmark.scale "Array.fromList >> Array.length"
                ([ 5 -- 18,625,505 runs/s (GoF: 99.96%)
                 , 50 -- 4,904,676 runs/s (GoF: 99.97%)
                 , 500 -- 856,094 runs/s (GoF: 99.95%)

                 --  , 5000 -- 84,065 runs/s (GoF: 99.79%)
                 ]
                    |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                    |> List.map (\( size, target ) -> ( toString size, \_ -> (Array.fromList >> Array.length) target ))
                )
            ]
    ]


toString : Int -> String
toString n =
    "n = " ++ String.fromInt n


replaceWithArray_code : List Content
replaceWithArray_code =
    [ pageHeader
        { chapter = "改善① List を Array に置き換える"
        , title = "実装の変更"
        }
    , highlightElm """{-| スタート時の各車両の順位を求める関数
    暫定的に1周目の通過タイムの早かった順で代用している
-}
startPositions : Array Wec.Lap -> List String
startPositions laps =
    Array.filter (\\{ lapNumber } -> lapNumber == 1) laps
        |> Array.toList
        |> List.sortBy .elapsed
        |> List.map .carNumber"""
    ]


{-| <https://github.com/y047aka/elm-motorsport-analysis/pull/4/commits/fc830456108acf98ebb9a9ed65e81032d0b85637>
-}
replaceWithArray_benchmark : List Content
replaceWithArray_benchmark =
    [ pageHeader
        { chapter = "改善① List を Array に置き換える"
        , title = "ベンチマーク"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ Benchmark.scale "startPositions_list"
                ([ 5 -- 10,777,648 runs/s (GoF: 99.95%)
                 , 50 -- 2,137,145 runs/s (GoF: 99.93%)
                 , 500 -- 206,667 runs/s (GoF: 99.84%)
                 , 5000 -- 21,238 runs/s (GoF: 99.85%)
                 ]
                    |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                    |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.startPositions_list target ))
                )
            , Benchmark.scale "startPositions_array"
                ([ 5 -- 3,936,471 runs/s (GoF: 99.95%)
                 , 50 -- 1,500,727 runs/s (GoF: 99.97%)
                 , 500 -- 230,693 runs/s (GoF: 99.96%)
                 , 5000 -- 22,697 runs/s (GoF: 99.96%)
                 ]
                    |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                    |> List.map (\( size, target ) -> ( toString size, \_ -> startPositions_array (Array.fromList target) ))
                )
            ]
    ]


startPositions_array : Array Wec.Lap -> List String
startPositions_array laps =
    Array.filter (\{ lapNumber } -> lapNumber == 1) laps
        |> Array.toList
        |> List.sortBy .elapsed
        |> List.map .carNumber


replaceWithArray_result : List Content
replaceWithArray_result =
    [ pageHeader
        { chapter = "改善① List を Array に置き換える"
        , title = "結果"
        }
    , markdownPage """
- 困ったこと
    - Arrayを操作する関数があまり提供されていない
        - そのため、ArrayをListに変換する処理を挟むことになる
        - その場合にも若干のパフォーマンス向上はあるけど...
- 解決策
    - Arrayを操作する関数を自作する
"""
    ]


replaceWithDict_overview : List Content
replaceWithDict_overview =
    [ pageHeader
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "概要"
        }
    , markdownPage """
- 課題
    - AssocListを使用しているため、検索に線形時間が必要
    - データ量が増えると処理時間が比例して増加
- 改善の方針
    - Dictを使用して検索を定数時間に改善
- 期待される効果
    - 大規模データでの処理速度の向上
"""
    ]


replaceWithDict_comparison : List Content
replaceWithDict_comparison =
    [ pageHeader
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "AssocList と Dictの比較"
        }
    , markdownPage """
- AssocList
    - キーと値のペアをリストで管理（任意の型をキーにできる）
    - 線形検索が必要（O(n)）
    - メモリ使用量が少ない
- Dict
    - ハッシュベースの実装
    - 定数時間でのアクセスが可能（O(1)）
    - メモリ使用量が多い
"""
    ]


replaceWithDict_ordersByLap_benchmark : List Content
replaceWithDict_ordersByLap_benchmark =
    [ pageHeader
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "ベンチマーク：ordersByLap"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ Benchmark.scale "ordersByLap_list"
                ([ 5 -- 1,290,015 runs/s (GoF: 99.97%)
                 , 50 -- 71,653 runs/s (GoF: 99.98%)
                 , 500 -- 625 runs/s (GoF: 99.99%)

                 --  , 5000 -- 46 runs/s (GoF: 99.97%)
                 ]
                    |> List.map (\size -> ( size, Fixture.csvDecodedOfSize size ))
                    |> List.map (\( size, target ) -> ( toString size, \_ -> Beginning.ordersByLap_list target ))
                )
            , Benchmark.scale "ordersByLap_dict"
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


replaceWithDict_preprocess_benchmark : List Content
replaceWithDict_preprocess_benchmark =
    [ pageHeader
        { chapter = "改善② AssocList を Dict に置き換える"
        , title = "ベンチマーク：preprocess_"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ let
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
              Benchmark.compare "preprocess_"
                "old"
                -- 349 runs/s (GoF: 99.99%)
                (\_ -> Beginning.preprocess_ options_beginning)
                "improved"
                -- 2,215 runs/s (GoF: 99.95%)
                (\_ -> Data.Wec.Preprocess.Dict.preprocess_ options_dict)
            ]
    ]


improve_logic_overview : List Content
improve_logic_overview =
    [ pageHeader
        { chapter = "改善③：計算ロジックを改良する"
        , title = "概要"
        }
    , markdownPage """
- 課題
    - 不要な計算の繰り返し
- 改善の方針
    - 計算の効率化
        - 中間結果の再利用
    - アルゴリズムの改善
        - 計算量の削減
"""
    ]


improve_logic_laps_benchmark : List Content
improve_logic_laps_benchmark =
    [ pageHeader
        { chapter = "改善③：計算ロジックを改良する"
        , title = "ベンチマーク：laps_"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ let
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
    ]


improve_logic_preprocess_benchmark : List Content
improve_logic_preprocess_benchmark =
    [ pageHeader
        { chapter = "改善③：計算ロジックを改良する"
        , title = "ベンチマーク：preprocess_"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ let
                options =
                    { carNumber = "15"
                    , laps = Fixture.csvDecodedForCarNumber "15"
                    , startPositions = Beginning.startPositions_list Fixture.csvDecoded
                    , ordersByLap = Beginning.ordersByLap_list Fixture.csvDecoded
                    }
              in
              Benchmark.compare "preprocess_"
                "old"
                -- 349 runs/s (GoF: 99.99%)
                (\_ -> Beginning.preprocess_ options)
                "improved"
                -- 2,215 runs/s (GoF: 99.95%)
                (\_ -> Data.Wec.Preprocess.preprocess_ options)
            ]
    ]


improve_logic_benchmark : List Content
improve_logic_benchmark =
    [ pageHeader
        { chapter = "改善③：計算ロジックを改良する"
        , title = "ベンチマーク：preprocess"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess.preprocess"
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
    [ pageHeader
        { chapter = "改善④：入力データ形式の変更"
        , title = "CSVからJSONへの移行"
        }
    , markdownPage """
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
    Decode.decodeString (Decode.list jsonDecoder) json

-- 処理速度: CSV vs JSON
-- CSV: 0.9 seconds
-- JSON: 0.4 seconds (55%改善)"""
    ]


replaceWithJson_benchmark : List Content
replaceWithJson_benchmark =
    [ pageHeader
        { chapter = "改善④：入力データ形式の変更"
        , title = "ベンチマーク：xxxDecoded"
        }
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ Benchmark.compare "xxxDecoded"
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
    ]


lessonsLearned : List Content
lessonsLearned =
    [ pageHeader
        { chapter = "ベンチマークから得られた知見"
        , title = "データ構造とパフォーマンスの関係"
        }
    , markdownPage """
- データ構造選択の影響度（List vs Array）
- 専用デコーダーの重要性
- データ量とパフォーマンスの関係性
- Elm特有の最適化ポイント
"""
    , highlightCode """-- 最初の実装と最終実装の比較
-- 処理速度: 初期実装 vs 最適化後
-- 初期実装: 2.4 seconds
-- 最適化後: 0.4 seconds (83%改善)

主な改善ポイント:
1. 専用デコーダーの利用
2. 適切なデータ構造の選択
3. 入力データ形式の最適化"""
    ]


realWorldApplications : List Content
realWorldApplications =
    [ pageHeader
        { chapter = "ベンチマークから得られた知見"
        , title = "実務でのパフォーマンス最適化"
        }
    , markdownPage """
- データ処理と DOM操作の違い
- The Elm Architectureでのパフォーマンス考慮点
- 実務での優先順位の決め方
"""
    , highlightElm """-- パフォーマンス問題の主な種類:
1. 初期化時間の遅さ (大量データの初期ロード)
2. 更新処理の遅さ (Updateサイクルの最適化)
3. 描画の遅さ (DOM操作の最小化)

-- The Elm Architectureでの最適化
-- Html.Lazy, Html.Keyed の活用
-- モデル設計の見直し"""
    ]


conclusion : List Content
conclusion =
    [ background "assets/images/cover_20231202.jpg"
        (markdown """
# まとめ

- 検証結果の総括: 適切な最適化で大幅な改善が可能
- 効果的な最適化アプローチ
- 測定してから最適化することの重要性
- 今後の展望

[サンプルコードとベンチマーク結果](https://github.com/y047aka/elm-benchmark-example)
""")
    ]
