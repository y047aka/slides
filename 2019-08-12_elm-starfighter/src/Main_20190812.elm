module Main_20190812 exposing (main)

import Custom exposing (Content, Msg)
import Formatting exposing (bullet, bulletLink, bullets, code, colored, padded, spacer, text_, title)
import Html exposing (br, h1, li, ol, p, span, text)
import Html.Attributes exposing (style)
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
    [ cover
    , jsLibraries
    , intro
    , characteristic
    , policy
    , usage
    , start
    , build
    ]


cover : List Content
cover =
    [ colored
        "hsl(345, 100%, 37%)"
        "#FFF"
        [ item
            (h1 []
                [ span [ style "font-size" "5rem" ] [ text "Elm入門のための開発テンプレート" ]
                , br [] []
                , span [ style "font-size" "15rem" ] [ text "elm-starfighter" ]
                ]
            )
        , spacer 100
        , text_ "Yoshitaka Totsuka"
        ]
    ]


jsLibraries : List Content
jsLibraries =
    [ padded
        [ title "モジュールバンドラーは必要？"
        , text_ "JavaScript の開発では、ESlint や Babel が必要とされ、"
        , spacer 0
        , text_ "それらのライブラリを制御するために、"
        , spacer 0
        , text_ "モジュールバンドラーが大活躍しています。"
        , spacer 50
        , text_ "しかし、Elm にはコンパイラがあるので、"
        , spacer 0
        , text_ "それらに頼らない開発が可能なはずです。"
        ]
    ]


intro : List Content
intro =
    [ padded
        [ title "elm-starfighter とは？"
        , text_ "Elmでの開発に必要な最低限を、"
        , spacer 0
        , text_ "シンプルに使うためのテンプレートです。"
        , bullets
            [ bulletLink "y047aka/elm-starfighter" "https://github.com/y047aka/elm-starfighter"
            ]
        ]
    ]


characteristic : List Content
characteristic =
    [ padded
        [ title "特徴"
        , bullets
            [ bullet "モジュールバンドラーを使用しない"
            , bullet "npm scripts に処理を記述する"
            ]
        ]
    ]


policy : List Content
policy =
    [ padded
        [ title "開発の方針"
        , bullets
            [ item
                (li []
                    [ text "Elm入門者に優しく"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ text "公式ガイドや『基礎からわかるElm』を読んだあとで、すぐに使えるように" ]
                    ]
                )
            , item
                (li []
                    [ text "Elmの魅力を引き出す"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ text "elm make のデバッグ機能なども使えるように" ]
                    ]
                )
            , item
                (li []
                    [ text "モジュールバンドラーと戦わない"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ text "Portsを積極的に使うならモジュールバンドラーの方が有利のはず" ]
                    ]
                )
            ]
        ]
    ]


usage : List Content
usage =
    [ padded
        [ title "簡単に使えるので書くことがない"
        , text_ "いちばん簡単な試し方"
        , code """
$ git clone https://github.com/y047aka/elm-starfighter.git
$ cd elm-startfighter
$ npm install
$ npm start
"""
        , spacer 30
        , item
            (p [ style "font-size" "2.8rem", style "color" "#999" ]
                [ text "リポジトリのトップから緑色のボタン「Use this template」を選択すると、"
                , br [] []
                , text "elm-starfighter を使った新しいリポジトリを作る事もできます。"
                ]
            )
        ]
    ]


start : List Content
start =
    [ padded
        [ title "npm start"
        , text_ "npm start を実行すると、"
        , item
            (ol []
                [ li [] [ text "docs にファイルが生成され" ]
                , li [] [ text "開発用サーバーが起動し" ]
                , li [] [ text "ブラウザに最初のページが表示されます" ]
                ]
            )
        ]
    ]


build : List Content
build =
    [ padded
        [ title "npm run build"
        , text_ "もう1つのコマンドは npm run build で起動します。"
        , item
            (ol []
                [ li [] [ text "public にファイルが生成されます" ]
                ]
            )
        , item
            (p [ style "font-size" "2.8rem", style "color" "#999" ]
                [ text "生成前のファイルはすべて src にあるので、いつも通りに開発を進められます。"
                ]
            )
        ]
    ]
