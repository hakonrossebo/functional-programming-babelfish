module Pages.Babelfish.ViewFullConcepts exposing (..)

import Html exposing (Html, text, div, span, p, a)
import Html.Attributes exposing (href)
import Material
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import Material.Elevation as Elevation
import Material.Table as Table
import Material.Icon as Icon
import Material.Tooltip as Tooltip
import Material.Typography as Typo
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Types exposing (Concept, LanguageImplementation, Taco, ConceptLink, Language)
import Markdown
import Pages.Babelfish.Helpers exposing (..)
import Pages.Babelfish.Messages exposing (..)
import Pages.Babelfish.Helpers exposing (..)


viewFullConceptSuccess : Taco -> Material.Model -> List Concept -> Html Msg
viewFullConceptSuccess taco outerMdl data =
    data
        |> List.indexedMap (\idx item -> viewFullConcept idx taco outerMdl item)
        |> div []


viewFullConcept : Int -> Taco -> Material.Model -> Concept -> Html Msg
viewFullConcept idx taco outerMdl concept =
    grid [ Options.id <| createConceptNameId concept.name, css "max-width" "1280px" ]
        [ cell
            [ size All 12
            , css "padding" "6px 4px"
            , css "display" "flex"
            , css "flex-direction" "row"
            , css "align-items" "left"
            ]
            [ Button.render Mdl
                [ 0, idx ]
                outerMdl
                [ Button.icon
                , Options.onClick (ScrollToDomId "top")
                ]
                [ Icon.view "arrow_upward" [ Tooltip.attach Mdl [ 0, idx ] ], Tooltip.render Mdl [ 0, idx ] outerMdl [] [ text "Back to top" ] ]
            , showText span Typo.headline concept.name
            ]
        , cell
            [ size All 12
            , css "padding" "6px 4px"
            , css "display" "flex"
            , css "flex-direction" "column"
            , css "align-items" "left"
            ]
            [ viewConceptLanguageCodeTable concept.languageImplementations
            ]
        , cell
            [ size All 12
              -- , Elevation.e2
            , css "padding" "6px 4px"
            , css "display" "flex"
            , css "flex-direction" "row"
            , css "align-items" "stretch"
            , css "justify-content" "flex-start"
            , css "align-content" "stretch"
            ]
            [ viewConceptNote concept.notes
            , viewConceptLinks concept.links
            ]
        , cell
            [ size All 12
            , css "padding" "6px 4px"
            , css "display" "flex"
            , css "flex-direction" "column"
            , css "align-items" "left"
            ]
            [ viewConceptLanguageExamples taco concept.languageImplementations
            ]
        ]

viewConceptNote : Maybe String -> Html Msg
viewConceptNote note =
    case note of
        Just note_ ->
            Options.div
                [ Elevation.e2
                , css "height" "196px"
                , css "flex" "1 0 auto"
                , css "overflow" "auto"
                , css "border-radius" "2px"
                , css "width" "500px"
                , css "margin-right" "1rem"
                , css "padding" "16px 16px 16px 16px"
                ]
                [ showText div Typo.caption "Notes"
                , text note_
                ]

        Nothing ->
            text ""


viewConceptLinks : List ConceptLink -> Html Msg
viewConceptLinks links =
    Options.div
        [ Elevation.e2
        , css "height" "196px"
        , css "flex" "1 0 auto"
        , css "overflow" "auto"
        , css "border-radius" "2px"
        , css "width" "500px"
        , css "margin-left" "1rem"
        , css "padding" "16px 16px 16px 16px"
        ]
        [ showText div Typo.caption "Links"
        , div []
            (links
                |> List.map (\link -> div [] [ a [ href link.url, Html.Attributes.target "_blank" ] [ text link.description ] ])
            )
        ]


viewConceptLanguageCodeTable : List LanguageImplementation -> Html Msg
viewConceptLanguageCodeTable languages =
    Table.table [ css "table-layout" "fixed", css "width" "100%" ]
        [ Table.thead
            []
            [ Table.tr []
                [ Table.th
                    [ css "width" "30%" ]
                    [ showText div Typo.body2 "Language"
                    ]
                , Table.th [ css "width" "70%" ]
                    [ showText div Typo.body2 "Code"
                    ]
                ]
            ]
        , Table.tbody []
            (languages
                |> List.indexedMap (\idx item -> viewConceptLanguageCodeTableItem idx item)
            )
        ]


viewConceptLanguageCodeTableItem : Int -> LanguageImplementation -> Html Msg
viewConceptLanguageCodeTableItem index language =
    Table.tr
        []
        [ Table.td [ css "text-align" "left" ] [ text language.name ]
        , Table.td [ css "text-align" "left" ] [ text language.code ]
        ]


viewConceptLanguageExamples : Taco -> List LanguageImplementation -> Html Msg
viewConceptLanguageExamples taco languages =
    Options.div
        [ Elevation.e2
          -- , css "height" "196px"
        , css "flex" "1 1 auto"
        , css "overflow" "auto"
        , css "border-radius" "2px"
        , css "width" "97%"
        , css "margin-top" "1rem"
        , css "padding" "16px 16px 16px 16px"
        ]
        [ showText div Typo.caption "Examples"
        , div []
            (languages
                |> List.map (\language -> viewLanguageConceptExample taco.availableLanguages language)
            )
        ]


viewLanguageConceptExample : List Language -> LanguageImplementation -> Html Msg
viewLanguageConceptExample availableLanguages language =
    case language.example of
        Just example ->
            let
                languageHighlightCodeName =
                    availableLanguages
                        |> List.filter (\lang -> lang.name == language.name)
                        |> List.map (\lang -> lang.languageCode)
                        |> List.head
                        |> Maybe.withDefault "haskell"
            in
                viewLanguageConceptExampleContainer language.name languageHighlightCodeName example

        Nothing ->
            text ""


viewLanguageConceptExampleContainer : String -> String -> List String -> Html Msg
viewLanguageConceptExampleContainer name hightlightCodeName insideHtml =
    let
        combinedExample =
            insideHtml
            |> List.foldr (\first next -> String.append first (String.append "\n" next) ) ""
    in
    Options.div
        [ --Elevation.e2
          -- , css "height" "196px"
          css "flex" "1 1 auto"
        , css "overflow" "auto"
        , css "border-radius" "2px"
          -- , css "width"  "528px"
          -- , css "margin-top" "4rem"
        , css "padding" "16px 16px 16px 16px"
        ]
        [ showText div Typo.caption name
        , viewFormattedLanguageExample hightlightCodeName [] combinedExample
        ]


viewFormattedLanguageExample : String -> List (Options.Property c m) -> String -> Html m
viewFormattedLanguageExample language options str =
    Options.styled
        (Markdown.toHtmlWith Markdown.defaultOptions)
        (Options.many
            [ css "overflow" "auto"
            , css "flex" "1 1 auto"
              -- , css "border-radius" "2px"
              -- , css "font-size" "10pt"
              -- , Color.background (Color.color Color.BlueGrey Color.S50)
            , css "background" "#002b36"
              -- , css "background" "#23241f"
            , css "color" "#fefefe"
            , css "padding" "6px 6px 6px 6px"
              -- , Elevation.e2
            ]
            :: options
        )
        ("```" ++ language ++ "\n" ++ str ++ "\n```")
