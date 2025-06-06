module Formatting.Styled exposing (background, col, color, colored, highlightCode, highlightElm, image, markdown, markdownPage, noPointerEvents, padded, page, position, row, spacer, title)

import Css exposing (..)
import Css.Global exposing (children, everything)
import Html.Styled as Html exposing (Html, a, code, div, h1, header, img, text)
import Html.Styled.Attributes as Attributes exposing (css, href, rel, src)
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)
import SliceShow.Content exposing (Content, container, item)
import SyntaxHighlight exposing (elm, noLang, toBlockHtml)


slidePadding : Css.Style
slidePadding =
    padding2 (px 20) (px 80)


padded : List (Html msg) -> Html msg
padded =
    div [ css [ slidePadding ] ]


page : PageHeader -> List (Content model msg) -> List (Content model msg)
page props contents =
    [ container
        (List.map Html.fromUnstyled
            >> div
                [ css
                    [ height (pct 100)
                    , padding (em 0.8)
                    , displayFlex
                    , flexDirection column
                    , property "row-gap" "0.8em"
                    , backgroundColor (hsl 200 1 0.4)
                    , Css.color (hsl 0 0 1)
                    ]
                ]
            >> Html.toUnstyled
        )
        (pageHeader props :: contents)
    ]


background : String -> List (Html msg) -> Content model msg
background url children =
    item <|
        Html.toUnstyled <|
            div
                [ css
                    [ Css.height (pct 100)
                    , boxSizing borderBox
                    , padding3 (px 10) (px 100) (px 20)
                    , backgroundColor (hex "222")
                    , Css.property "background-image"
                        ("linear-gradient(rgba(0,0,0,0.75), rgba(0,0,0,0.75)), url('" ++ url ++ "')")
                    , backgroundSize Css.cover
                    , backgroundPosition center
                    , backgroundRepeat noRepeat
                    , Css.color (hex "FFF")
                    ]
                ]
                children


spacer : Int -> Html msg
spacer h =
    div [ css [ Css.height (px (toFloat h)) ] ] []


image : Int -> Int -> String -> Content model msg
image w h url =
    item <|
        Html.toUnstyled <|
            img
                [ src url
                , Attributes.width w
                , Attributes.height h
                , css [ maxWidth (pct 100), borderRadius (px 10) ]
                ]
                []


colored : String -> String -> List (Html msg) -> Content model msg
colored color1 color2 children =
    item <|
        Html.toUnstyled <|
            div
                [ css
                    [ Css.height (pct 100)
                    , boxSizing borderBox
                    , slidePadding
                    , property "background-color" color1
                    , property "color" color2
                    ]
                ]
                children


title : String -> Html msg
title txt =
    h1 [] [ text txt ]


type alias PageHeader =
    { chapter : String
    , title : String
    }


pageHeader : PageHeader -> Content model msg
pageHeader props =
    item <|
        Html.toUnstyled <|
            header
                [ css
                    [ displayFlex
                    , flexDirection column
                    , property "row-gap" "1rem"
                    , children
                        [ everything
                            [ margin zero, lineHeight (num 1) ]
                        ]
                    ]
                ]
                [ div [ css [ fontSize (em 0.6), fontWeight bold ] ]
                    [ text props.chapter ]
                , h1 [ css [ fontSize (em 0.8), fontWeight normal ] ]
                    [ text props.title ]
                ]


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


markdown : String -> List (Html msg)
markdown markdownStr =
    Markdown.Parser.parse markdownStr
        |> Result.mapError (always "")
        |> Result.andThen (Markdown.Renderer.render customizedHtmlRenderer)
        |> Result.withDefault []


markdownPage : String -> Content model msg
markdownPage markdownStr =
    markdown markdownStr
        |> div [ css [ padding2 zero (em 2) ] ]
        |> Html.toUnstyled
        |> item


customizedHtmlRenderer : Renderer (Html msg)
customizedHtmlRenderer =
    { heading =
        \{ level, children } ->
            case level of
                Block.H1 ->
                    Html.h1 [ css [ margin zero, fontSize (em 1.4) ] ] children

                Block.H2 ->
                    Html.h2
                        [ css
                            [ fontSize (em 1)
                            , fontWeight normal
                            , nthOfType "n+2" [ margin3 (em 1.8) zero zero ]
                            ]
                        ]
                        children

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
            Html.ul [ css [ margin2 (em 0.6) zero ] ]
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
                                    Html.li [ css [ margin2 (em 0.4) zero ] ] (checkbox :: children)
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
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "br" (\children -> Html.br [] children) ]
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
            Html.pre [ css [ width (pct 100), overflow hidden, fontSize (em 0.6) ] ]
                [ Html.code classes
                    [ Html.text body
                    ]
                ]
    , thematicBreak = Html.hr [] []
    , table =
        Html.table
            [ css
                [ width (pct 100)
                , borderCollapse collapse
                , fontSize (rem 2.4)
                ]
            ]
    , tableHeader = Html.thead []
    , tableBody = Html.tbody []
    , tableRow = Html.tr []
    , tableHeaderCell =
        \maybeAlignment ->
            Html.th
                [ css
                    [ padding (px 15)
                    , textAlign center
                    , fontWeight normal
                    , border3 (px 1) solid (hsla 0 0 1 0.8)
                    ]
                ]
    , tableCell =
        \maybeAlignment ->
            Html.td
                [ css
                    [ padding (px 15)
                    , textAlign center
                    , border3 (px 1) solid (hsla 0 0 1 0.8)
                    ]
                ]
    }


{-| Elmコードのシンタックスハイライト表示用ヘルパー関数
-}
highlightElm : String -> Content model msg
highlightElm code =
    item <|
        Html.toUnstyled <|
            case elm code of
                Ok highlighted ->
                    div [ css [ overflow hidden, borderRadius (px 10) ] ]
                        [ Html.fromUnstyled (toBlockHtml (Just 1) highlighted) ]

                Err _ ->
                    Html.pre [] [ Html.code [] [ text code ] ]


{-| 汎用コードのシンタックスハイライト表示用ヘルパー関数
-}
highlightCode : String -> Content model msg
highlightCode code =
    item <|
        Html.toUnstyled <|
            case noLang code of
                Ok highlighted ->
                    Html.fromUnstyled (toBlockHtml (Just 1) highlighted)

                Err _ ->
                    Html.pre [] [ Html.code [] [ text code ] ]
