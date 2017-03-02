module Pages.Babelfish.ViewConceptMatrix exposing (..)

import Html exposing (Html, text, div, span, p, a)
import Material
import Material.Menu as Menu
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import RemoteData exposing (WebData, RemoteData(..))
import Material.Table as Table
import Material.Icon as Icon
import Material.Tooltip as Tooltip
import Material.Typography as Typo
import Types exposing (Concept, LanguageImplementation, Taco)
import Pages.Babelfish.Helpers exposing (..)
import Pages.Babelfish.Messages exposing (..)
import Pages.Babelfish.Helpers exposing (..)

type alias RowLanguageImplementations =
    List String


type ConceptLanguagesViewModel
    = NotCreated
    | Created RowLanguageImplementations (List ( RowLanguageImplementations, RowLanguageImplementations ))

createConceptLanguagesViewModel : List String -> WebData (List Concept) -> ConceptLanguagesViewModel
createConceptLanguagesViewModel displayLanguages concepts =
    case concepts of
        Success data ->
            let
                header =
                    displayLanguages

                rows =
                    data
                        |> List.map (\concept -> createConceptLanguagesViewModelRow displayLanguages concept.languageImplementations concept.name concept.description)
            in
                Created header rows

        _ ->
            NotCreated


createConceptLanguagesViewModelRow : List String -> List LanguageImplementation -> String -> String -> ( RowLanguageImplementations, RowLanguageImplementations )
createConceptLanguagesViewModelRow displayLanguages languageImplementations name desc =
    let
        languages =
            displayLanguages
                |> List.map (\lang -> findLanguageImplementation lang languageImplementations)
    in
        ( [ name, desc ], languages )


findLanguageImplementation : String -> List LanguageImplementation -> String
findLanguageImplementation lang languageImplementations =
    languageImplementations
        |> List.filter (\x -> x.name == lang)
        |> List.map (\x -> x.code)
        |> List.head
        |> Maybe.withDefault ""



viewConceptsMatrixSuccess : Taco -> List String -> Material.Model -> RowLanguageImplementations -> List ( RowLanguageImplementations, RowLanguageImplementations ) -> Html Msg
viewConceptsMatrixSuccess taco displayLanguages outerMdl header rows =
    let
        descriptions =
            [ Table.th
                [ css "width" "30%"
                , css "vertical-align" "middle"
                ]
                [ showText div Typo.body2 "Concept"
                ]
            , Table.th
                [ css "width" "10%"
                , css "vertical-align" "middle"
                ]
                [ showText div Typo.body2 "Name"
                ]
            ]

        availableWidth =
            60

        languageColumnSize =
            displayLanguages
                |> List.length
                |> (//) availableWidth
                |> toString

        languageNames =
            displayLanguages
                |> List.indexedMap (\idx lang -> viewConceptLanguageHeader idx taco displayLanguages outerMdl languageColumnSize lang)
    in
        Table.table [ css "table-layout" "fixed", css "width" "100%" ]
            [ Table.thead
                []
                [ Table.tr [] (List.append descriptions languageNames)
                ]
            , Table.tbody []
                (rows
                    |> List.indexedMap (\idx item -> viewConceptItem idx item outerMdl)
                )
            ]


viewConceptLanguageHeader : Int -> Taco -> List String -> Material.Model -> String -> String -> Html Msg
viewConceptLanguageHeader index taco displayLanguages outerMdl size name =
    Table.th
        [ css "text-align" "left"
        , css "align-items" "center"
        ]
        [ Options.styled span [ Typo.body2, Typo.left, Typo.justify ] [ text name ]
        , viewLanguageSelectMenu index taco displayLanguages outerMdl name
        ]


viewLanguageSelectMenu : Int -> Taco -> List String -> Material.Model -> String -> Html Msg
viewLanguageSelectMenu index taco displayLanguages outerMdl language =
    Menu.render Mdl
        [ index ]
        outerMdl
        [ css "float" "right"
        , Menu.ripple
        , Menu.bottomLeft
        , Menu.icon "keyboard_arrow_down"
        ]
        (getMenuItems language taco displayLanguages)


getMenuItems : String -> Taco -> List String -> List (Menu.Item Msg)
getMenuItems currentLanguage taco displayLanguages =
    taco.availableLanguages
        |> List.filter (\availableLanguage -> not (List.any (\language -> language == availableLanguage.name) displayLanguages))
        |> List.map (\language -> viewMenuItem currentLanguage language.name)


viewMenuItem : String -> String -> Menu.Item Msg
viewMenuItem currentLanguage newLanguage =
    Menu.item
        [ Menu.onSelect (SelectLanguage currentLanguage newLanguage) ]
        [ text newLanguage ]



viewConceptItem : Int -> ( RowLanguageImplementations, RowLanguageImplementations ) -> Material.Model -> Html Msg
viewConceptItem idx ( descRow, codeRow ) outerMdl =
    let
        code =
            codeRow
                |> List.map (\row -> viewConceptLanguage row)

        desc =
            descRow
                |> List.indexedMap (\idx row -> viewConceptLanguageDescription idx outerMdl row)
    in
        List.append desc code
            |> Table.tr []


viewConceptLanguageDescription : Int -> Material.Model -> String -> Html Msg
viewConceptLanguageDescription idx outerMdl descriptionText =
    let
        content =
            if idx == 0 then
                [ Button.render Mdl
                    [ 1, idx ]
                    outerMdl
                    [ Button.icon
                    , Options.onClick (ScrollToDomId <| createConceptNameId descriptionText)
                    ]
                    [ Icon.view "zoom_in" [ Tooltip.attach Mdl [ 1, idx ] ], Tooltip.render Mdl [ 1, idx ] outerMdl [] [ text "Go to details" ] ]
                , text descriptionText
                ]
            else
                [ text descriptionText ]
    in
        Table.td [ css "text-align" "left", css "background-color" "#f6f6f6", cs "wrapword" ] (content)


viewConceptLanguage : String -> Html Msg
viewConceptLanguage code =
    Table.td [ css "text-align" "left", cs "wrapword" ] [ text code ]
