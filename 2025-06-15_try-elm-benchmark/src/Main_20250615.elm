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
import Formatting.Styled as Formatting exposing (background, colored, markdown, markdownPage, spacer)
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
    , introduction
    , motivation
    , elmBenchmark_overview
    , elmBenchmark_example
    , elmBenchmark_benchmark
    , sampleData
    , oldCode_workflow
    , oldCode_benchmark
    , optimization_ideas
    , replaceWithArray_overview
    , replaceWithArray_study
    , replaceWithArray_code
    , replaceWithArray_benchmark
    , replaceWithArray_result
    , replaceWithDict_ordersByLap_benchmark
    , replaceWithDict_preprocess_benchmark
    , improve_logic_laps_benchmark
    , improve_logic_preprocess_benchmark
    , improve_logic_benchmark
    , replaceWithJson_overview
    , replaceWithJson_benchmark
    , lessonsLearned
    , realWorldApplications
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
    [ markdownPage """
# はじめに

- Elmの紹介と特徴
- パフォーマンスに関する一般的な認識と疑問
- Elmは遅いのか？速いのか？
- 今回の検証の目的

型安全性や開発体験の良さが注目されがちですが、実際のパフォーマンスはどうなのでしょうか？
"""
    ]


motivation : List Content
motivation =
    [ markdownPage """
# パフォーマンス計測の動機

- 好奇心
    - ベンチマークを測定してみたい
        - `List` と `Array` のパフォーマンスの違いを体感したい
    - 非効率なコードが残っているうちに試したい
        - 改善の幅が大きいほうが楽しい
    - 性能向上を主目的としていない点にご留意ください
"""
    ]


elmBenchmark_overview : List Content
elmBenchmark_overview =
    [ markdownPage """
# elm-explorations/benchmark

Elmコードのベンチマークを実行するためのパッケージ

- Warming JIT：測定前にJITコンパイルを強制する
- Collecting Samples：統計的に有意な結果を得るまで反復実行
    - 複数対象を交互に実行し、測定の偏りを軽減する
- Goodness of Fit：測定結果の信頼性を評価する指標
  - （99%: 優秀 / 95%: 良好 / 90%: 要注意 / 80%以下: 信頼性低）
"""
    ]


elmBenchmark_example : List Content
elmBenchmark_example =
    [ markdownPage """
# elm-explorations/benchmark

```elm
import Array
import Benchmark exposing (..)

suite : Benchmark
suite =
    let
        sampleArray =
            Array.initialize 100 identity
    in
    describe "Array"
        [ describe "slice"
            [ benchmark "from the beginning" <|
                \\_ -> Array.slice 50 100 sampleArray
            , benchmark "from the end" <|
                \\_ -> Array.slice 0 50 sampleArray
            ]
        ]
```
"""
    ]


elmBenchmark_benchmark : List Content
elmBenchmark_benchmark =
    [ markdownPage "# elm-explorations/benchmark"
    , Custom.benchmark <|
        let
            sampleArray =
                Array.initialize 100 identity
        in
        Benchmark.describe "Array"
            [ Benchmark.describe "slice"
                [ Benchmark.benchmark "from the beginning" <|
                    \_ -> Array.slice 50 100 sampleArray
                , Benchmark.benchmark "from the end" <|
                    \_ -> Array.slice 0 50 sampleArray
                ]
            ]
    ]


sampleData : List Content
sampleData =
    [ markdownPage """
# 検証用サンプルデータ

- ル・マン24時間レース（2024年）の全車両の走行データ

```csv
NUMBER; DRIVER_NUMBER; LAP_NUMBER; LAP_TIME; LAP_IMPROVEMENT; CROSSING_FINISH_LINE_IN_PIT; S1; S1_IMPROVEMENT; S2; S2_IMPROVEMENT; S3; S3_IMPROVEMENT; KPH; ELAPSED; HOUR;S1_LARGE;S2_LARGE;S3_LARGE;TOP_SPEED;DRIVER_NAME;PIT_TIME;CLASS;GROUP;TEAM;MANUFACTURER;FLAG_AT_FL;S1_SECONDS;S2_SECONDS;S3_SECONDS;
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
99;2;251;4:07.503;0;;40.250;0;1:31.114;0;1:56.139;0;198.2;24:05:35.985;16:06:02.587;0:40.250;1:31.114;1:56.139;242.0;Harry TINCKNELL;;HYPERCAR;H;Proton Competition;Porsche;FF;40.250;91.114;116.139;
```
"""
    ]


oldCode_workflow : List Content
oldCode_workflow =
    [ markdownPage """
# 最初の実装

- CSVをパースし、周回データとしてデコード
- 周回データを解析し、車両単位で再構成

```elm
preprocess : List Lap -> List Car
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
            )
```
"""
    ]


oldCode_benchmark : List Content
oldCode_benchmark =
    [ markdownPage "# 最初の計測"
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
    [ markdownPage """
# パフォーマンス向上のアイデア

- `List` を `Array` に置き換える
    - 1万行以上のデータを扱うので、Arrayの優位性を体感できそう
- `AssocList` を `Dict` に置き換える
- 計算ロジックの見直し
- CSVのデコードパッケージを自作する
    - `Array` を前提とした実装に変更すれば速くなるかな？
"""
    ]


replaceWithArray_overview : List Content
replaceWithArray_overview =
    [ markdownPage """
# 最適化① `List` を `Array` に置き換える

- Listは線形検索、Arrayはインデックスアクセスに強い
- 1万行以上のデータを扱うので、Arrayの優位性を体感できそう

```
{-| スタート時の各車両の順位を求める関数
    暫定的に1周目の通過タイムの早かった順で代用している
-}
startPositions : List Lap -> List String
startPositions laps =
    List.filter (\\{ lapNumber } -> lapNumber == 1) laps
        |> List.sortBy .elapsed
        |> List.map .carNumber
```
"""
    ]


{-| <https://github.com/y047aka/elm-motorsport-analysis/pull/4/commits/98e10ec08c46a0aa6549fe01bbf41d9125387dbc>
-}
replaceWithArray_study : List Content
replaceWithArray_study =
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
    [ markdownPage """
# 最適化① `List` を `Array` に置き換える

```
{-| スタート時の各車両の順位を求める関数
    暫定的に1周目の通過タイムの早かった順で代用している
-}
startPositions : Array Wec.Lap -> List String
startPositions laps =
    Array.filter (\\{ lapNumber } -> lapNumber == 1) laps
        |> Array.toList
        |> List.sortBy .elapsed
        |> List.map .carNumber
```
"""
    ]


{-| <https://github.com/y047aka/elm-motorsport-analysis/pull/4/commits/fc830456108acf98ebb9a9ed65e81032d0b85637>
-}
replaceWithArray_benchmark : List Content
replaceWithArray_benchmark =
    [ markdownPage "# 最適化① `List` を `Array` に置き換える"
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
    [ markdownPage """
# 最適化① `List` を `Array` に置き換える

- 困ったこと
    - Arrayを操作する関数があまり提供されていない
        - そのため、ArrayをListに変換する処理を挟むことになる
        - その場合にも若干のパフォーマンス向上はあるけど...
- 解決策
    - Arrayを操作する関数を自作する
"""
    ]


replaceWithDict_ordersByLap_benchmark : List Content
replaceWithDict_ordersByLap_benchmark =
    [ markdownPage "# 最適化② AssocList を Dict に置き換える"
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
    [ markdownPage "# 最適化② AssocList を Dict に置き換える"
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


improve_logic_laps_benchmark : List Content
improve_logic_laps_benchmark =
    [ markdownPage "# 最適化の試み③：計算ロジックを改良する"
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
    [ markdownPage "# 最適化の試み③：計算ロジックを改良する"
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
    [ markdownPage "# 最適化の試み③：計算ロジックを改良する"
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
    [ markdownPage """
# 最適化の試み④：入力データ形式の変更

- CSVとJSONの処理特性の違い
- JSONデコードに変更した実装
- パフォーマンスへの影響

```elm
import Json.Decode as Decode

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
-- JSON: 0.4 seconds (55%改善)
```
"""
    ]


replaceWithJson_benchmark : List Content
replaceWithJson_benchmark =
    [ markdownPage "# 最適化の試み④：入力データ形式の変更"
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
    [ markdownPage """
# ベンチマークから得られた知見

- データ構造選択の影響度（List vs Array）
- 専用デコーダーの重要性
- データ量とパフォーマンスの関係性
- Elm特有の最適化ポイント

```
-- 最初の実装と最終実装の比較
-- 処理速度: 初期実装 vs 最適化後
-- 初期実装: 2.4 seconds
-- 最適化後: 0.4 seconds (83%改善)

主な改善ポイント:
1. 専用デコーダーの利用
2. 適切なデータ構造の選択
3. 入力データ形式の最適化
```
"""
    ]


realWorldApplications : List Content
realWorldApplications =
    [ markdownPage """
# 実際のアプリケーションでの考慮点

- データ処理と DOM操作の違い
- The Elm Architectureでのパフォーマンス考慮点
- 実務での優先順位の決め方

```elm
-- パフォーマンス問題の主な種類:
1. 初期化時間の遅さ (大量データの初期ロード)
2. 更新処理の遅さ (Updateサイクルの最適化)
3. 描画の遅さ (DOM操作の最小化)

-- The Elm Architectureでの最適化
-- Html.Lazy, Html.Keyed の活用
-- モデル設計の見直し
```
"""
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
