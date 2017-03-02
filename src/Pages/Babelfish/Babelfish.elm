module Pages.Babelfish.Babelfish exposing (..)

import Html exposing (Html, text, div, span, p, a)
import Html.Attributes exposing (href)
import Material
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import Material.Typography as Typo
import Material.Table as Table
import Material.Menu as Menu
import Material.Icon as Icon
import Material.Tooltip as Tooltip
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)
import Decoders exposing (..)
import Http exposing (Error)
import Pages.Babelfish.Messages exposing (..)
import Pages.Babelfish.ViewConceptMatrix as ViewConceptMatrix
import Pages.Babelfish.Helpers exposing (..)
import CustomPorts exposing (..)
import Markdown

styles : String
styles =
    """\x0D\x0D\x0D\x0D
   .mdl-layout__drawer {\x0D\x0D\x0D\x0D
      border: none !important;\x0D\x0D\x0D\x0D
   }\x0D\x0D\x0D\x0D
   """


type alias Model =
    { mdl : Material.Model
    , concepts : WebData (List Concept)
    , displayLanguages : List String
    , conceptLanguagesViewModel : ConceptLanguagesViewModel
    }




subs : Model -> Sub Msg
subs model =
    Menu.subs Mdl model.mdl


init : Taco -> ( Model, Cmd Msg )
init taco =
    let
        languages =
            List.take 4 taco.availableLanguages
                |> List.map (\language -> language.name)
    in
        ( { mdl = Material.model
          , concepts = RemoteData.NotAsked
          , displayLanguages = languages
          , conceptLanguagesViewModel = NotCreated
          }
        , fetchData
        )


fetchData : Cmd Msg
fetchData =
    Cmd.batch
        [ fetchConcepts
        ]


fetchConcepts : Cmd Msg
fetchConcepts =
    Http.get "concepts.json" decodeConcepts
        |> RemoteData.sendRequest
        |> Cmd.map ConceptsResponse


update : Msg -> Model -> ( Model, Cmd Msg, SharedMsg )
update msg model =
    case msg of
        Mdl msg_ ->
            let
                ( model_, cmd_ ) =
                    Material.update Mdl msg_ model
            in
                ( model_, cmd_, NoSharedMsg )

        ScrollToDomId id ->
            ( model, scrollIdIntoView id, NoSharedMsg )

        ConceptsResponse response ->
            ( { model | concepts = response, conceptLanguagesViewModel = createConceptLanguagesViewModel model.displayLanguages response }, Cmd.none, NoSharedMsg )

        SelectLanguage currentLanguage language ->
            let
                displayLanguages =
                    updateDisplayLanguages currentLanguage language model.displayLanguages

                conceptLanguagesViewModel =
                    createConceptLanguagesViewModel displayLanguages model.concepts
            in
                ( { model | displayLanguages = displayLanguages, conceptLanguagesViewModel = conceptLanguagesViewModel }, Cmd.none, NoSharedMsg )


updateDisplayLanguages : String -> String -> List String -> List String
updateDisplayLanguages currentLanguage newLanguage displayLanguages =
    displayLanguages
        |> List.map
            (\language ->
                if currentLanguage == language then
                    newLanguage
                else
                    language
            )


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


view : Taco -> Model -> Html Msg
view taco model =
    grid [ Options.id "top", css "max-width" "1280px" ]
        [ cell
            [ size All 12
            , Elevation.e2
            , css "padding" "6px 4px"
            , css "display" "flex"
            , css "flex-direction" "column"
            , css "align-items" "left"
            ]
            [ showText div Typo.body1 "This is an attempt to provide a link and comparision between similar concepts and operations and their usage between different functional programming languages . When learning and working with different languages and concepts, it's nice to have an easy way of looking up the implementations. Please contribute! I am not an expert in these languages. Please contribute to improvements with PR's and issues to help improve this reference."
            , showText div Typo.body1 "The table is limited to showng 4 languages simultaneously. When there are more languages available, you can choose other languages in the table header menus."
            , viewConceptsMatrix taco model
            ]
        , cell
            [ size All 12
            , Elevation.e2
            , css "padding" "6px 4px"
            , css "display" "flex"
            , css "flex-direction" "column"
            , css "align-items" "left"
            ]
            [ showText div Typo.display1 "Concept details"
            , viewFullConcepts taco model
            ]
        ]


white : Options.Property a b
white =
    Color.text Color.white


viewConceptsMatrix : Taco -> Model -> Html Msg
viewConceptsMatrix taco model =
    case model.conceptLanguagesViewModel of
        NotCreated ->
            text "Initialising."

        Created header rows ->
            ViewConceptMatrix.viewConceptsMatrixSuccess taco model.displayLanguages model.mdl header rows



viewFullConcepts : Taco -> Model -> Html Msg
viewFullConcepts taco model =
    case model.concepts of
        NotAsked ->
            text "Initialising."

        Loading ->
            text "Loading."

        Failure err ->
            text ("Error: " ++ toString err)

        Success data ->
            viewFullConceptSuccess taco model data


viewFullConceptSuccess : Taco -> Model -> List Concept -> Html Msg
viewFullConceptSuccess taco model data =
    data
        |> List.indexedMap (\idx item -> viewFullConcept idx taco model.mdl item)
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


viewLanguageConceptExampleContainer : String -> String -> String -> Html Msg
viewLanguageConceptExampleContainer name hightlightCodeName insideHtml =
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
        , viewFormattedLanguageExample hightlightCodeName [] insideHtml
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
