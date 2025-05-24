module Main_20250615 exposing (main)

import Array exposing (Array)
import Css exposing (..)
import Custom exposing (Content, Msg)
import Data.Fixture as Fixture
import Data.Wec.Decoder as Wec
import Dict
import Formatting.Styled as Formatting exposing (background, colored, markdown, markdownPage, spacer)
import Html.Styled as Html exposing (br, h1, img, span, text)
import Html.Styled.Attributes exposing (css, src)
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
    , elmBenchmark_1
    , elmBenchmark_2
    , elmBenchmark_3
    , sampleData
    , exampleCode
    , benchmark
    , optimizationIdeas
    , listToArray_1
    , listLengthVsArrayLength
    , listToArray_2
    , listToArray_3
    , listToArray_4
    , optimization2
    , optimization3
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
        , text "2025-06-15"
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
    - 一度くらい elm-benchmark を使ってみたい
    - `List` と `Array` のパフォーマンスの違いを知りたい
- 非効率なコードが残っているうちに試したい
    - 改善の幅が大きいほうが楽しい
"""
    ]


elmBenchmark_1 : List Content
elmBenchmark_1 =
    [ markdownPage """
# elm-benchmark

- Elmコードの性能測定ツール
    - JITコンパイル最適化を考慮したウォームアップ処理
        - JavaScriptエンジンの挙動を理解した正確な測定
    - 統計的に有意な結果を得るための反復実行機能
    - わかりやすい視覚的出力（グラフ表示）
"""
    ]


elmBenchmark_2 : List Content
elmBenchmark_2 =
    [ markdownPage """
# elm-benchmark

```elm
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


elmBenchmark_3 : List Content
elmBenchmark_3 =
    [ markdownPage "# elm-benchmark"
    , Custom.benchmark <|
        let
            dest =
                Dict.singleton "a" 1
        in
        Benchmark.describe "sample"
            [ Benchmark.describe "dictionary"
                [ Benchmark.benchmark "get" (\_ -> Dict.get "a" dest)
                , Benchmark.benchmark "insert" (\_ -> Dict.insert "b" 2 dest)
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


exampleCode : List Content
exampleCode =
    [ markdownPage """
# 最初の実装

```elm
{-| CSVをパースし、周回データとしてデコードする -}
csvDecoded : List Wec.Lap
csvDecoded =
    csv
        |> Csv.Decode.decodeCustom { fieldSeparator = ';' } FieldNamesFromFirstRow lapDecoder
        |> Result.withDefault []

{-| 周回データを車両単位で前処理する -}
preprocess : List Wec.Lap -> List Car
preprocess laps =
    laps
        |> AssocList.Extra.groupBy .carNumber
        |> AssocList.toList
        |> List.map
            (\\( carNumber, laps_ ) ->
                preprocess_deprecated
                    { carNumber = carNumber
                    , laps = laps_
                    , startPositions = startPositions
                    , ordersByLap = ordersByLap
                    }
            )
```
"""
    ]


benchmark : List Content
benchmark =
    [ markdownPage "# 最初の計測"
    ]


optimizationIdeas : List Content
optimizationIdeas =
    [ markdownPage """
# 最適化のアイデア

- `List` を `Array` に置き換える
    - 1万行以上のデータを扱うので効果を期待できるかもしれない？
- `AssocList` を `Dict` に置き換える
- CSVのデコードパッケージを自作する
    - デコード結果を `Array` で受け取ることができれば早くなるのでは？
"""
    ]


listToArray_1 : List Content
listToArray_1 =
    [ markdownPage """
# 最適化①：`List` を `Array` に置き換える

- 測定結果から判明した問題点: 大量データのリスト処理が遅い
- Listは線形検索、Arrayはインデックスアクセスに強い
- 1万行以上のCSVデータには特に効果的な可能性
"""
    ]


{-| <https://github.com/y047aka/elm-motorsport-analysis/pull/4/commits/98e10ec08c46a0aa6549fe01bbf41d9125387dbc>
-}
listLengthVsArrayLength : List Content
listLengthVsArrayLength =
    [ Custom.benchmark <|
        Benchmark.describe "Array" <|
            [ Benchmark.compare "length"
                "List.length"
                (\_ ->
                    -- 296,394 runs/s (GoF: 99.99%)
                    List.length Fixture.csvDecoded
                )
                "Array.length"
                (\_ ->
                    -- 290,366,954 runs/s (GoF: 99.99%)
                    Array.length Fixture.csvDecoded_array
                )
            , Benchmark.compare "fromList >> length"
                "List.length"
                (\_ ->
                    -- 296,512 runs/s (GoF: 99.98%)
                    List.length Fixture.csvDecoded
                )
                "Array.length"
                (\_ ->
                    -- 644,729 runs/s (GoF: 99.99%)
                    (Array.fromList >> Array.length) Fixture.csvDecoded
                )
            ]
    ]


listToArray_2 : List Content
listToArray_2 =
    [ markdownPage """
# 最適化①：`List` を `Array` に置き換える

TODO: 改善後のコードを表示
"""
    ]


{-| <https://github.com/y047aka/elm-motorsport-analysis/pull/4/commits/fc830456108acf98ebb9a9ed65e81032d0b85637>
-}
listToArray_3 : List Content
listToArray_3 =
    [ markdownPage """
# 計測①：`List` を `Array` に置き換える

TODO: elm-benchmarkの結果を表示
"""
    , Custom.benchmark <|
        Benchmark.describe "Data.Wec.Preprocess"
            [ Benchmark.scale "startPositions_list"
                ([ 0 -- 32,796,129 runs/s (GoF: 99.97%)
                 , 100 -- 847,795 runs/s (GoF: 99.99%)
                 , 200 -- 398,531 runs/s (GoF: 99.99%)
                 , 500 -- 153,345 runs/s (GoF: 99.98%)
                 ]
                    |> List.map (\size -> ( size, csvDecodedOfSize size ))
                    |> List.map (\( size, target ) -> ( "n = " ++ String.fromInt size, \_ -> startPositions_list target ))
                )
            , Benchmark.scale "startPositions_array"
                ([ 0 -- 10,061,597 runs/s (GoF: 99.99%)
                 , 100 -- 817,089 runs/s (GoF: 99.97%)
                 , 200 -- 484,857 runs/s (GoF: 99.96%)
                 , 500 -- 202,018 runs/s (GoF: 99.94%)
                 ]
                    |> List.map (\size -> ( size, csvDecodedOfSize size ))
                    |> List.map (\( size, target ) -> ( "n = " ++ String.fromInt size, \_ -> startPositions_array (Array.fromList target) ))
                )
            ]
    ]


csvDecodedOfSize : Int -> List Wec.Lap
csvDecodedOfSize size =
    List.take size Fixture.csvDecoded


startPositions_list : List Wec.Lap -> List String
startPositions_list laps =
    List.filter (\{ lapNumber } -> lapNumber == 1) laps
        |> List.sortBy .elapsed
        |> List.map .carNumber


startPositions_array : Array Wec.Lap -> List String
startPositions_array laps =
    Array.filter (\{ lapNumber } -> lapNumber == 1) laps
        |> Array.toList
        |> List.sortBy .elapsed
        |> List.map .carNumber


listToArray_4 : List Content
listToArray_4 =
    [ markdownPage """
# 最適化①：`List` を `Array` に置き換える

TODO: 測定結果の分析を表示
"""
    ]


optimization2 : List Content
optimization2 =
    [ markdownPage """
# 最適化の試み②：本当のボトルネックを探る

- プロファイリングによるボトルネック特定
- 改善策の検討と実装（遅延評価パターンの適用など）
- 改善前後の比較

```elm
import Csv.Decode as Decode
import Csv

-- 文字列分割とパースが最大のボトルネック

csvDecoder : Decode.Decoder CsvData
csvDecoder =
    Decode.map3 CsvData
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "value" Decode.float)

processCsvData : String -> Result Decode.Error (List CsvData)
processCsvData csv =
    Decode.decodeCsv Decode.FieldNamesFromFirstRow csvDecoder csv

-- 処理速度: 手動実装 vs csvデコーダー
-- 手動実装: 1.8 seconds
-- csvデコーダー: 0.9 seconds (50%改善)
```
"""
    ]


optimization3 : List Content
optimization3 =
    [ markdownPage """
# 最適化の試み③：入力データ形式の変更

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
