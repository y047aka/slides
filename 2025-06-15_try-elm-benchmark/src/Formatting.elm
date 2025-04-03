module Formatting exposing (background, bullet, bulletLink, bullets, code, col, color, colored, group, image, noPointerEvents, padded, position, row, spacer, text_, title)

import Html
import Html.Attributes exposing (height, href, src, style, target, width)
import SliceShow.Content exposing (Content, container, item)


slidePadding : String
slidePadding =
    "20px 100px"


padded : List (Content a b) -> Content a b
padded =
    Html.div [ style "padding" slidePadding ]
        |> container


background : String -> List (Content a b) -> Content a b
background url =
    container
        (Html.div
            [ style "height" "100%"
            , style "box-sizing" "border-box"
            , style "padding" "10px 100px 20px"
            , style "background-image" ("url(" ++ url ++ ")")
            , style "background-size" "cover"
            , style "color" "#FFF"
            , style "text-shadow" "0 0 50px #000"
            ]
        )


spacer : Int -> Content model msg
spacer h =
    item (Html.div [ style "height" (String.fromInt h ++ "px") ] [])


image : Int -> Int -> String -> Content model msg
image w h url =
    item
        (Html.img
            [ src url
            , width w
            , height h
            ]
            []
        )


colored : String -> String -> List (Content a b) -> Content a b
colored color1 color2 =
    Html.div
        [ style "height" "100%"
        , style "box-sizing" "border-box"
        , style "padding" slidePadding
        , style "background" color1
        , style "color" color2
        ]
        |> container


title : String -> Content model msg
title txt =
    item (Html.h1 [] [ Html.text txt ])


text_ : String -> Content model msg
text_ txt =
    item (Html.span [] [ Html.text txt ])


position : Int -> Int -> Content model msg -> Content model msg
position left top content =
    container
        (Html.div
            [ style "position" "absolute"
            , style "left" (String.fromInt left ++ "px")
            , style "top" (String.fromInt top ++ "px")
            ]
        )
        [ content ]


color : String -> Content model msg -> Content model msg
color c content =
    container (Html.div [ style "color" c ]) [ content ]


col : List (Content model msg) -> Content model msg
col =
    container
        (Html.div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "align-items" "center"
            ]
        )


row : List (Content model msg) -> Content model msg
row contents =
    container
        (Html.div
            [ style "display" "flex"
            , style "justify-content" "space-around"
            , style "width" "100%"
            ]
        )
        contents


group : Int -> Int -> Int -> Int -> List (Content model msg) -> Content model msg
group left top width height content =
    container
        (Html.div
            [ style "position" "absolute"
            , style "left" (String.fromInt left ++ "px")
            , style "top" (String.fromInt top ++ "px")
            , style "width" (String.fromInt width ++ "px")
            , style "height" (String.fromInt height ++ "px")
            ]
        )
        content


noPointerEvents : Content model msg -> Content model msg
noPointerEvents content =
    container
        (Html.div [ style "pointer-events" "none" ])
        [ content ]


bullets : List (Content model msg) -> Content model msg
bullets =
    container (Html.ul [])


bullet : String -> Content model msg
bullet str =
    item (Html.li [] [ Html.text str ])


bulletLink : String -> String -> Content model msg
bulletLink str url =
    item
        (Html.li []
            [ Html.a
                [ href url
                , target "_blank"
                , style "color" "inherit"
                ]
                [ Html.text str ]
            ]
        )


{-| Code block
-}
code : String -> Content model msg
code str =
    item
        (Html.pre [ style "margin" "0", style "line-height" "0.5" ]
            [ Html.code [ style "font" "1.8rem monospace", style "margin" "0" ] [ Html.text str ]
            ]
        )
