module Formatting.Styled exposing (Tag(..), background, col, color, colored, highlightCode, highlightElm, image, markdown, markdownPage, nextButton, noPointerEvents, padded, page, position, prevButton, row, spacer, tagCloud, title)

import Css exposing (..)
import Css.Global exposing (children, everything)
import Html
import Html.Attributes exposing (style)
import Html.Styled exposing (Html, a, code, div, h1, header, img, span, text)
import Html.Styled.Attributes as Attributes exposing (css, href, rel, src)
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)
import SliceShow exposing (Content, container, item)
import SyntaxHighlight exposing (HCode, elm, noLang, toBlockHtml)


prevButton : ( Int, Int ) -> Content model msg
prevButton ( wid, height ) =
    SliceShow.prev
        [ style "width" (String.fromInt wid ++ "px")
        , style "height" (String.fromInt height ++ "px")
        , style "background" "none"
        , style "border" "none"
        , style "padding" "0"
        , style "margin" "0"
        , style "cursor" "pointer"
        ]
        []


nextButton : ( Int, Int ) -> Content model msg
nextButton ( wid, height ) =
    SliceShow.next
        [ style "width" (String.fromInt wid ++ "px")
        , style "height" (String.fromInt height ++ "px")
        , style "background" "none"
        , style "border" "none"
        , style "padding" "0"
        , style "margin" "0"
        , style "cursor" "pointer"
        ]
        []


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


slidePadding : Css.Style
slidePadding =
    padding2 (px 20) (px 80)


padded : List (Html msg) -> Html msg
padded =
    div [ css [ slidePadding ] ]


page : PageHeader -> List (Content model msg) -> List (Content model msg)
page props contents =
    [ container
        (List.map Html.Styled.fromUnstyled
            >> div
                [ css
                    [ height (pct 100)
                    , padding (em 0.8)
                    , displayFlex
                    , flexDirection column
                    , property "row-gap" "0.8em"
                    , backgroundColor (hsl 200 0.1 0.85)
                    , Css.color (hsl 0 0 0.2)
                    ]
                ]
            >> Html.Styled.toUnstyled
        )
        (pageHeader props :: contents)
    ]


background : String -> List (Html Never) -> Content model msg
background url children =
    item <|
        Html.Styled.toUnstyled <|
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
        Html.Styled.toUnstyled <|
            img
                [ src url
                , Attributes.width w
                , Attributes.height h
                , css [ maxWidth (pct 100), borderRadius (px 10) ]
                ]
                []


colored : String -> String -> List (Html Never) -> Content model msg
colored color1 color2 children =
    item <|
        Html.Styled.toUnstyled <|
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
        Html.Styled.toUnstyled <|
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
        |> Html.Styled.toUnstyled
        |> item


customizedHtmlRenderer : Renderer (Html msg)
customizedHtmlRenderer =
    { heading =
        \{ level, children } ->
            case level of
                Block.H1 ->
                    Html.Styled.h1 [ css [ margin zero, fontSize (em 1.4) ] ] children

                Block.H2 ->
                    Html.Styled.h2
                        [ css
                            [ fontSize (em 1)
                            , nthOfType "n+2" [ margin3 (em 1.8) zero zero ]
                            ]
                        ]
                        children

                Block.H3 ->
                    Html.Styled.h3 [] children

                Block.H4 ->
                    Html.Styled.h4 [] children

                Block.H5 ->
                    Html.Styled.h5 [] children

                Block.H6 ->
                    Html.Styled.h6 [] children
    , paragraph = Html.Styled.p []
    , hardLineBreak = Html.Styled.br [] []
    , blockQuote = Html.Styled.blockquote []
    , strong =
        \children -> Html.Styled.strong [] children
    , emphasis =
        \children -> Html.Styled.em [] children
    , strikethrough =
        \children -> Html.Styled.del [] children
    , codeSpan =
        \content -> Html.Styled.code [] [ Html.Styled.text content ]
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
                    Html.Styled.img
                        [ Attributes.src imageInfo.src
                        , Attributes.alt imageInfo.alt
                        , Attributes.title title_
                        ]
                        []

                Nothing ->
                    Html.Styled.img
                        [ Attributes.src imageInfo.src
                        , Attributes.alt imageInfo.alt
                        ]
                        []
    , text =
        Html.Styled.text
    , unorderedList =
        \items ->
            Html.Styled.ul [ css [ margin2 (em 0.6) zero ] ]
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
                                                    Html.Styled.text ""

                                                Block.IncompleteTask ->
                                                    Html.Styled.input
                                                        [ Attributes.disabled True
                                                        , Attributes.checked False
                                                        , Attributes.type_ "checkbox"
                                                        ]
                                                        []

                                                Block.CompletedTask ->
                                                    Html.Styled.input
                                                        [ Attributes.disabled True
                                                        , Attributes.checked True
                                                        , Attributes.type_ "checkbox"
                                                        ]
                                                        []
                                    in
                                    Html.Styled.li [ css [ margin2 (em 0.4) zero ] ] (checkbox :: children)
                        )
                )
    , orderedList =
        \startingIndex items ->
            Html.Styled.ol
                (case startingIndex of
                    1 ->
                        [ Attributes.start startingIndex ]

                    _ ->
                        []
                )
                (items
                    |> List.map
                        (\itemBlocks ->
                            Html.Styled.li []
                                itemBlocks
                        )
                )
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "br" (\children -> Html.Styled.br [] children) ]
    , codeBlock =
        \{ body, language } ->
            let
                classes : List (Html.Styled.Attribute msg)
                classes =
                    -- Only the first word is used in the class
                    case Maybe.map String.words language of
                        Just (actualLanguage :: _) ->
                            [ Attributes.class <| "language-" ++ actualLanguage ]

                        _ ->
                            []
            in
            Html.Styled.pre [ css [ width (pct 100), overflow hidden, fontSize (em 0.6) ] ]
                [ Html.Styled.code classes
                    [ Html.Styled.text body
                    ]
                ]
    , thematicBreak = Html.Styled.hr [] []
    , table =
        Html.Styled.table
            [ css
                [ width (pct 100)
                , borderCollapse collapse
                , fontSize (rem 2.4)
                ]
            ]
    , tableHeader = Html.Styled.thead []
    , tableBody = Html.Styled.tbody []
    , tableRow = Html.Styled.tr []
    , tableHeaderCell =
        \maybeAlignment ->
            Html.Styled.th
                [ css
                    [ padding (px 15)
                    , textAlign center
                    , fontWeight normal
                    , border3 (px 1) solid (hsl 0 0 0.2)
                    ]
                ]
    , tableCell =
        \maybeAlignment ->
            Html.Styled.td
                [ css
                    [ padding (px 15)
                    , textAlign center
                    , border3 (px 1) solid (hsl 0 0 0.2)
                    ]
                ]
    }


{-| Elmコードのシンタックスハイライト表示用ヘルパー関数
-}
highlightElm : (HCode -> HCode) -> String -> Content model msg
highlightElm f code =
    item <|
        Html.Styled.toUnstyled <|
            case elm code of
                Ok highlighted ->
                    div [ css [ overflow hidden, borderRadius (px 10) ] ]
                        [ Html.Styled.fromUnstyled (toBlockHtml (Just 1) (f highlighted)) ]

                Err _ ->
                    Html.Styled.pre [] [ Html.Styled.code [] [ text code ] ]


{-| 汎用コードのシンタックスハイライト表示用ヘルパー関数
-}
highlightCode : String -> Content model msg
highlightCode code =
    item <|
        Html.Styled.toUnstyled <|
            case noLang code of
                Ok highlighted ->
                    Html.Styled.fromUnstyled (toBlockHtml (Just 1) highlighted)

                Err _ ->
                    Html.Styled.pre [] [ Html.Styled.code [] [ text code ] ]



-- Tag Cloud


type Tag
    = Green Float String
    | Red Float String
    | Gray Float String


tagCloud : List Tag -> Content model msg
tagCloud items =
    item <|
        Html.Styled.toUnstyled <|
            div
                [ css
                    [ height (pct 100)
                    , padding (px 20)
                    , property "display" "grid"
                    , property "place-items" "center"
                    ]
                ]
                [ div
                    [ css
                        [ textAlign center
                        , lineHeight (num 1.2)
                        , property "display" "flex"
                        , property "flex-wrap" "wrap"
                        , property "justify-content" "center"
                        , property "align-items" "center"
                        , property "gap" "20px 30px"
                        , maxWidth (px 1000)
                        , margin2 zero auto
                        ]
                    ]
                    (List.map tagItem items)
                ]


tagToCssColor : Tag -> Color
tagToCssColor tag =
    case tag of
        Green _ _ ->
            hsl 142 0.71 0.4

        Red _ _ ->
            hsl 0 0.6 0.5

        Gray _ _ ->
            hsl 220 0.09 0.5


tagItem : Tag -> Html msg
tagItem tag =
    let
        ( size, label ) =
            case tag of
                Green s l ->
                    ( s, l )

                Red s l ->
                    ( s, l )

                Gray s l ->
                    ( s, l )
    in
    span
        [ css
            [ fontSize (rem size)
            , Css.color (tagToCssColor tag)
            , if size >= 2.5 then
                fontWeight bold

              else if size >= 1.5 then
                fontWeight (int 600)

              else
                fontWeight (int 500)
            , display inlineBlock
            , padding2 (px 2) (px 6)
            , margin (px 2)
            , property "user-select" "none"
            , hover
                [ transform (scale 1.1)
                , Css.property "transition" "transform 0.2s ease"
                ]
            ]
        ]
        [ text label ]
