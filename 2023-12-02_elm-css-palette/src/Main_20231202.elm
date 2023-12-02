module Main_20231202 exposing (main)

import Custom exposing (Content, Msg)
import Formatting exposing (background, bullet, bulletLink, bullets, code, colored, padded, spacer, text_, title)
import Html exposing (a, br, h1, img, li, span, text)
import Html.Attributes exposing (href, src, style, target)
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
    , issue
    , howToUse
    , whatIsElmCssPalette
    , history
    , roadmap
    , ending
    ]


cover : List Content
cover =
    [ colored
        "hsl(200, 100%, 40%)"
        "#FFF"
        [ item
            (h1 []
                [ span [ style "font-size" "5rem" ] [ text "配色のデザイントークンを賢く管理したい！" ]
                , br [] []
                , span [ style "font-size" "14rem" ] [ text "elm-css-palette" ]
                ]
            )
        , spacer 50
        , item
            (img
                [ src "assets/images/y047aka.png"
                , style "width" "75px"
                , style "border-radius" "50%"
                ]
                []
            )
        , item
            (span
                [ style "position" "relative"
                , style "top" "-2rem"
                , style "padding-left" "0.5em"
                , style "font-size" "4.5rem"
                ]
                [ text "Yoshitaka Totsuka" ]
            )
        , spacer 20
        , text_ "Elm-jp 2023：川崎"
        , spacer 10
        , text_ "2023.12.02"
        ]
    ]


issue : List Content
issue =
    [ padded
        [ title "Issue"
        , bullets
            [ bullet "background, color, border を毎回記述するのはめんどくさい"
            , bullet "たくさんの配色が生まれると、全てを把握するのが大変！"
            ]
        , spacer 20
        , code """view : Html Msg
view =
    div
        [ css
            [ ...
            , background = hsl 0 0 1
            , color = hsl 0 0 0.4
            , border = hsl 0 0 0.7
            ]
        ]
        [ text "Usual Method" ]
"""
        ]
    ]


howToUse : List Content
howToUse =
    [ padded
        [ title "elm-css-palette"
        , code """light : Palette
light =
    { background = Just (hsl 0 0 1)
    , color = Just (hsl 0 0 0.4)
    , border = Just (hsl 0 0 0.7)
    }

view : Html Msg
view =
    div
        [ css
            [ ...
            , palette light
            ]
        ]
        [ text "Hello, Palette!" ]
"""
        ]
    ]


whatIsElmCssPalette : List Content
whatIsElmCssPalette =
    [ padded
        [ title "elm-css-palette とは？"
        , text_ "elm-cssと組み合わせることで、配色のデザイントークンを効率的に管理するためのパッケージです。"
        , bullets
            [ bulletLink "y047aka/elm-css-palette" "https://package.elm-lang.org/packages/y047aka/elm-css-palette/latest/"
            ]
        ]
    ]


history : List Content
history =
    [ padded
        [ title "History"
        , text_ ""
        , bullets
            [ bullet "最初は自分の新しいアイデアだと思っていた（2020〜）"
            , item
                (li []
                    [ text "調べてみると NoRedInk が同じようなことを試していた"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ a [ href "https://package.elm-lang.org/packages/NoRedInk/noredink-ui/latest/Nri-Ui-Palette-V1#Palette", target "_blank" ] [ text "Nri.Ui.Palette.V1 (NoRedInk/noredink-ui)" ] ]
                    , li [ style "margin-left" "1em" ] [ text "レコードを一括適用する関数は使っていなさそう" ]
                    ]
                )
            , item
                (li []
                    [ text "改良を加えてElm Packagesに公開（2023/11）"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ a [ href "https://package.elm-lang.org/packages/y047aka/elm-css-palette/latest/", target "_blank" ] [ text "y047aka/elm-css-palette" ] ]
                    ]
                )
            ]
        ]
    ]


roadmap : List Content
roadmap =
    [ padded
        [ title "Roadmap"
        , bullets
            [ item
                (li []
                    [ text "状態変化のバリエーションを管理できるようにする"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ text ":hover, :disabled, ダークモード など" ]
                    ]
                )
            , item
                (li []
                    [ text "CSS filterを管理できるようにする"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ a [ href "https://www.apple.com/apple-vision-pro/", target "_blank" ] [ text "ガラスのようなテクスチャ" ] ]
                    ]
                )
            , item
                (li []
                    [ text "OkColorをサポートする"
                    , br [] []
                    , span [ style "font-size" "2.4rem", style "color" "#999" ]
                        [ a [ href "https://bottosson.github.io/posts/oklab/", target "_blank" ] [ text "Oklab" ] -- and https://raphlinus.github.io/color/2021/01/18/oklab-critique.html
                        , text ", "
                        , a [ href "https://oklch.com/", target "_blank" ] [ text "Oklch" ]
                        , text ", "
                        , a [ href "https://bottosson.github.io/posts/colorpicker/", target "_blank" ] [ text "Okhsl" ]
                        ]
                    ]
                )
            ]
        ]
    ]


ending : List Content
ending =
    [ background "assets/images/cover_20231202.jpg"
        [ title "おしまい！"
        , bullets
            [ bullet "似たような事例があれば教えてください"
            , bullet "Blueskyやってます（https://bsky.app/profile/yoshitaka.bsky.social）"
            ]
        ]
    ]
