module Main_20250615 exposing (main)

import Css exposing (..)
import Custom exposing (Content, Msg)
import Formatting.Styled as Formatting exposing (background, colored, markdownPage, markdownWithTitle, spacer)
import Html.Styled as Html exposing (Html, br, h1, img, span, text)
import Html.Styled.Attributes exposing (css, src)
import SliceShow exposing (Message, Model, init, setSubscriptions, setUpdate, setView, show)
import SliceShow.Content exposing (item)
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
    List.map (List.map (Html.toUnstyled >> item))
        [ cover
        , introduction
        , benchmarkSetup
        , sampleCode
        , optimization1
        , optimization2
        , optimization3
        , lessonsLearned
        , realWorldApplications
        , conclusion
        ]


cover : List (Html msg)
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


introduction : List (Html msg)
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


benchmarkSetup : List (Html msg)
benchmarkSetup =
    [ markdownPage """
# ベンチマーク環境の準備

- [elm-benchmarkの紹介と基本的な使い方](https://package.elm-lang.org/packages/elm-explorations/benchmark/latest/)
- ベンチマークの結果解釈と注意点（JITコンパイルの影響など）
- 測定環境と条件の説明

```elm
import Benchmark exposing (Benchmark, describe, benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)

main : BenchmarkProgram
main =
    program suite

suite : Benchmark
suite =
    describe "CSV Processing Performance"
        [ benchmark "Process 10k rows" processCsvData
        ]
```
"""
    ]


sampleCode : List (Html msg)
sampleCode =
    [ markdownPage """
# 検証用サンプルコード

- 1万行のCSVをデコード＆前処理するサンプルコード
- 初期実装の説明とパフォーマンス測定
- ボトルネックの予測

```elm
type alias CsvData =
    { id : Int
    , name : String
    , value : Float
    }

processCsvData : String -> List CsvData
processCsvData csv =
    csv
        |> String.lines
        |> List.drop 1  -- ヘッダー行をスキップ
        |> List.map parseCsvLine

parseCsvLine : String -> CsvData
parseCsvLine line =
    case String.split "," line of
        [ idStr, name, valueStr ] ->
            { id = String.toInt idStr |> Maybe.withDefault 0
            , name = name
            , value = String.toFloat valueStr |> Maybe.withDefault 0
            }
        _ ->
            { id = 0, name = "", value = 0 }
```
"""
    ]


optimization1 : List (Html msg)
optimization1 =
    [ markdownPage """
# 最適化の試み①：データ構造の選択

- List と Array の特性比較
- List を Array に置き換えた実装
- パフォーマンスの変化と考察
- その他のデータ構造の考慮点（Record vs Tuple、カスタムタイプ設計）

```elm
import Array exposing (Array)

processCsvData : String -> Array CsvData
processCsvData csv =
    csv
        |> String.lines
        |> List.drop 1  -- ヘッダー行をスキップ
        |> List.map parseCsvLine
        |> Array.fromList

-- 処理速度: List実装 vs Array実装
-- List: 2.4 seconds
-- Array: 1.8 seconds (25%改善)
```
"""
    ]


optimization2 : List (Html msg)
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


optimization3 : List (Html msg)
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


lessonsLearned : List (Html msg)
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


realWorldApplications : List (Html msg)
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


conclusion : List (Html msg)
conclusion =
    [ background "assets/images/cover_20231202.jpg"
        [ markdownWithTitle """
# まとめ

- 検証結果の総括: 適切な最適化で大幅な改善が可能
- 効果的な最適化アプローチ
- 測定してから最適化することの重要性
- 今後の展望

[サンプルコードとベンチマーク結果](https://github.com/y047aka/elm-benchmark-example)
"""
        ]
    ]
