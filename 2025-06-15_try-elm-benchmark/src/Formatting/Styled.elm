module Formatting.Styled exposing (background, bullet, bulletLink, bullets, code, col, color, colored, group, image, noPointerEvents, padded, position, row, spacer, title)

import Css exposing (..)
import Html.Styled as Html exposing (Html, a, div, h1, img, li, text, ul)
import Html.Styled.Attributes as Attributes exposing (css, href, src)


slidePadding : Css.Style
slidePadding =
    padding2 (px 20) (px 100)


padded : List (Html msg) -> Html msg
padded =
    div [ css [ slidePadding ] ]


background : String -> List (Html msg) -> Html msg
background url =
    div
        [ css
            [ Css.height (pct 100)
            , boxSizing borderBox
            , padding3 (px 10) (px 100) (px 20)
            , backgroundImage (Css.url url)
            , backgroundSize Css.cover
            , Css.color (hex "FFF")
            , textShadow4 zero zero (px 50) (hex "000")
            ]
        ]


spacer : Int -> Html msg
spacer h =
    div [ css [ Css.height (px (toFloat h)) ] ] []


image : Int -> Int -> String -> Html msg
image w h url =
    img
        [ src url
        , Attributes.width w
        , Attributes.height h
        ]
        []


colored : String -> String -> List (Html msg) -> Html msg
colored color1 color2 =
    div
        [ css
            [ Css.height (pct 100)
            , boxSizing borderBox
            , slidePadding
            , property "background-color" color1
            , property "color" color2
            ]
        ]


title : String -> Html msg
title txt =
    h1 [] [ text txt ]


position : Int -> Int -> Html msg -> Html msg
position left top content =
    div
        [ css
            [ Css.position absolute
            , Css.left (px (toFloat left))
            , Css.top (px (toFloat top))
            ]
        ]
        [ content ]


color : String -> Html msg -> Html msg
color c content =
    div [ css [ property "color" c ] ] [ content ]


col : List (Html msg) -> Html msg
col =
    div
        [ css
            [ displayFlex
            , flexDirection column
            , alignItems center
            ]
        ]


row : List (Html msg) -> Html msg
row contents =
    div
        [ css
            [ displayFlex
            , justifyContent spaceAround
            , Css.width (pct 100)
            ]
        ]
        contents


group : Int -> Int -> Int -> Int -> List (Html msg) -> Html msg
group left top width_ height_ content =
    div
        [ css
            [ Css.position absolute
            , Css.left (px (toFloat left))
            , Css.top (px (toFloat top))
            , Css.width (px (toFloat width_))
            , Css.height (px (toFloat height_))
            ]
        ]
        content


noPointerEvents : Html msg -> Html msg
noPointerEvents content =
    div [ css [ pointerEvents none ] ]
        [ content ]


bullets : List (Html msg) -> Html msg
bullets =
    ul []


bullet : String -> Html msg
bullet str =
    li [] [ text str ]


bulletLink : String -> String -> Html msg
bulletLink str url =
    li []
        [ a
            [ href url
            , Attributes.target "_blank"
            , css [ Css.color inherit ]
            ]
            [ text str ]
        ]


{-| Code block
-}
code : String -> Html msg
code str =
    Html.pre
        [ css [ margin zero, lineHeight (num 0.5) ] ]
        [ Html.code
            [ css
                [ fontFamilies [ "monospace" ]
                , fontSize (rem 1.8)
                , margin zero
                ]
            ]
            [ text str ]
        ]
