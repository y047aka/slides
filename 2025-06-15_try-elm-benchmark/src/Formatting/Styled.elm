module Formatting.Styled exposing (background, col, color, colored, image, markdown, markdownPage, noPointerEvents, padded, position, row, spacer, title)

import Css exposing (..)
import Html.Styled as Html exposing (Html, a, div, h1, img, text)
import Html.Styled.Attributes as Attributes exposing (css, href, rel, src)
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)


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


noPointerEvents : Html msg -> Html msg
noPointerEvents content =
    div [ css [ pointerEvents none ] ]
        [ content ]


markdown : String -> Html msg
markdown markdownStr =
    Markdown.Parser.parse markdownStr
        |> Result.mapError (always "")
        |> Result.andThen (Markdown.Renderer.render customizedHtmlRenderer)
        |> Result.withDefault []
        |> div []


markdownPage : String -> Html msg
markdownPage markdownStr =
    padded [ markdown markdownStr ]


customizedHtmlRenderer : Renderer (Html msg)
customizedHtmlRenderer =
    { heading =
        \{ level, children } ->
            case level of
                Block.H1 ->
                    Html.h1 [] children

                Block.H2 ->
                    Html.h2 [] children

                Block.H3 ->
                    Html.h3 [] children

                Block.H4 ->
                    Html.h4 [] children

                Block.H5 ->
                    Html.h5 [] children

                Block.H6 ->
                    Html.h6 [] children
    , paragraph = Html.p []
    , hardLineBreak = Html.br [] []
    , blockQuote = Html.blockquote []
    , strong =
        \children -> Html.strong [] children
    , emphasis =
        \children -> Html.em [] children
    , strikethrough =
        \children -> Html.del [] children
    , codeSpan =
        \content -> Html.code [] [ Html.text content ]
    , link =
        \link children ->
            let
                externalLinkAttrs =
                    -- Markdown記法で記述されたリンクについて、参照先が外部サイトであれば新しいタブで開くようにする
                    if isExternalLink link.destination then
                        [ Attributes.target "_blank", rel "noopener" ]

                    else
                        []

                isExternalLink url =
                    let
                        isProduction =
                            String.startsWith url "/"

                        isLocalDevelopment =
                            String.startsWith url "/"
                    in
                    not (isProduction || isLocalDevelopment)

                titleAttrs =
                    link.title
                        |> Maybe.map (\title_ -> [ Attributes.title title_ ])
                        |> Maybe.withDefault []
            in
            a (href link.destination :: externalLinkAttrs ++ titleAttrs) children
    , image =
        \imageInfo ->
            case imageInfo.title of
                Just title_ ->
                    Html.img
                        [ Attributes.src imageInfo.src
                        , Attributes.alt imageInfo.alt
                        , Attributes.title title_
                        ]
                        []

                Nothing ->
                    Html.img
                        [ Attributes.src imageInfo.src
                        , Attributes.alt imageInfo.alt
                        ]
                        []
    , text =
        Html.text
    , unorderedList =
        \items ->
            Html.ul []
                (items
                    |> List.map
                        (\item ->
                            case item of
                                Block.ListItem task children ->
                                    let
                                        checkbox : Html msg
                                        checkbox =
                                            case task of
                                                Block.NoTask ->
                                                    Html.text ""

                                                Block.IncompleteTask ->
                                                    Html.input
                                                        [ Attributes.disabled True
                                                        , Attributes.checked False
                                                        , Attributes.type_ "checkbox"
                                                        ]
                                                        []

                                                Block.CompletedTask ->
                                                    Html.input
                                                        [ Attributes.disabled True
                                                        , Attributes.checked True
                                                        , Attributes.type_ "checkbox"
                                                        ]
                                                        []
                                    in
                                    Html.li [] (checkbox :: children)
                        )
                )
    , orderedList =
        \startingIndex items ->
            Html.ol
                (case startingIndex of
                    1 ->
                        [ Attributes.start startingIndex ]

                    _ ->
                        []
                )
                (items
                    |> List.map
                        (\itemBlocks ->
                            Html.li []
                                itemBlocks
                        )
                )
    , html = Markdown.Html.oneOf []
    , codeBlock =
        \{ body, language } ->
            let
                classes : List (Html.Attribute msg)
                classes =
                    -- Only the first word is used in the class
                    case Maybe.map String.words language of
                        Just (actualLanguage :: _) ->
                            [ Attributes.class <| "language-" ++ actualLanguage ]

                        _ ->
                            []
            in
            Html.pre []
                [ Html.code classes
                    [ Html.text body
                    ]
                ]
    , thematicBreak = Html.hr [] []
    , table = Html.table []
    , tableHeader = Html.thead []
    , tableBody = Html.tbody []
    , tableRow = Html.tr []
    , tableHeaderCell =
        \maybeAlignment ->
            let
                attrs : List (Html.Attribute msg)
                attrs =
                    maybeAlignment
                        |> Maybe.map
                            (\alignment ->
                                case alignment of
                                    Block.AlignLeft ->
                                        "left"

                                    Block.AlignCenter ->
                                        "center"

                                    Block.AlignRight ->
                                        "right"
                            )
                        |> Maybe.map Attributes.align
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
            in
            Html.th attrs
    , tableCell =
        \maybeAlignment ->
            let
                attrs : List (Html.Attribute msg)
                attrs =
                    maybeAlignment
                        |> Maybe.map
                            (\alignment ->
                                case alignment of
                                    Block.AlignLeft ->
                                        "left"

                                    Block.AlignCenter ->
                                        "center"

                                    Block.AlignRight ->
                                        "right"
                            )
                        |> Maybe.map Attributes.align
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
            in
            Html.td attrs
    }
