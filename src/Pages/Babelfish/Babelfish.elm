module Pages.Babelfish.Babelfish exposing (..)

import Html exposing (Html, text, div, span, p, a)
import Material
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import Material.Typography as Typo
import Material.Table as Table
import Material.Dialog as Dialog
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)
import Decoders exposing (..)
import Http exposing (Error)
import Dropdown
import Pages.Babelfish.ConceptDetail as ConceptDetail
import Dict
import Markdown

styles : String
styles =
    """\x0D\x0D\x0D
   .mdl-layout__drawer {\x0D\x0D\x0D
      border: none !important;\x0D\x0D\x0D
   }\x0D\x0D\x0D
   """


type alias Model =
    { mdl : Material.Model
    , concepts : WebData (List Concept)
    , displayLanguages : List String
    , conceptLanguagesViewModel : ConceptLanguagesViewModel
    }


type Msg
    = Mdl (Material.Msg Msg)
    | ConceptsResponse (WebData (List Concept))


init : Taco -> ( Model, Cmd Msg )
init taco =
    let
        languages =
            taco.availableLanguages
            |> List.map (\language -> language.name)
    in
    ( { mdl = Material.model
      , concepts = RemoteData.NotAsked
      , displayLanguages = languages
      , conceptLanguagesViewModel = NotCreated }
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
            (model_, cmd_ ) =
              Material.update Mdl msg_ model
          in
              (model_, cmd_, NoSharedMsg)

        ConceptsResponse response ->
            ( { model | concepts = response, conceptLanguagesViewModel = createConceptLanguagesViewModel model response }, Cmd.none, NoSharedMsg)

createConceptLanguagesViewModel : Model -> WebData (List Concept) -> ConceptLanguagesViewModel
createConceptLanguagesViewModel model concepts =
    case concepts of
      Success data ->
        let
            header = model.displayLanguages
            rows =
              data
              |> List.map (\concept -> createConceptLanguagesViewModelRow model.displayLanguages concept.languageImplementations concept.name concept.description )
        in
          Created header rows
      _ ->
          NotCreated


createConceptLanguagesViewModelRow : List String -> List LanguageImplementation -> String -> String -> (RowLanguageImplementations, RowLanguageImplementations)
createConceptLanguagesViewModelRow displayLanguages languageImplementations name desc =
          let
            languages = displayLanguages
                |> List.map (\lang -> findLanguageImplementation lang languageImplementations)
          in
              ([name, desc], languages)

findLanguageImplementation : String -> List LanguageImplementation -> String
findLanguageImplementation lang languageImplementations =
    languageImplementations
    |> List.filter (\x -> x.language == lang)
    |> List.map (\x -> x.code)
    |> List.head
    |> Maybe.withDefault ""


view : Taco -> Model -> Html Msg
view taco model =
    let
        pieClass =
            "abc123"
    in
        grid [ Options.css "max-width" "1280px" ]
            [ cell
                [ size All 12
                , Elevation.e2
                , Options.css "padding" "6px 4px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                , Options.css "align-items" "left"
                ]
                [ showText div Typo.body1 "This is an attempt to provide a link and comparision between similar concepts and operations and their usage between different functional programming languages . When learning and working with different languages and concepts, it's nice to have an easy way of looking up the implementations. Please contribute! I am not an expert in these languages. Please contribute to improvements with PR's and issues to help improve this reference."
                , viewConcepts model
                ]
            , cell
                [ size All 12
                , Elevation.e2
                , Options.css "padding" "6px 4px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                , Options.css "align-items" "left"
                ]
                [ showText div Typo.display1 "Concept details"
                , viewFullConcepts model
                ]
            ]




showText : (List (Html.Attribute m) -> List (Html msg) -> a) -> Options.Property c m -> String -> a
showText elementType displayStyle text_ =
    Options.styled elementType [ displayStyle, Typo.left ] [ text text_ ]


white : Options.Property a b
white =
    Color.text Color.white


viewConcepts : Model -> Html Msg
viewConcepts model =
    case model.conceptLanguagesViewModel of
        NotCreated ->
            text "Initialising."
        Created header rows ->
            viewConceptsSuccess model header rows



viewConceptsSuccess : Model -> RowLanguageImplementations -> List (RowLanguageImplementations, RowLanguageImplementations) -> Html Msg
viewConceptsSuccess model header rows =
    let
      descriptions =
                [ Table.th
                    [ css "width" "30%" ]
                    [ showText div Typo.body2 "Concept"
                    ]
                , Table.th [ css "width" "10%" ]
                    [ showText div Typo.body2 "Name"
                    ]
                ]
      availableWidth =
          60
      languageColumnSize =
          model.displayLanguages
          |> List.length
          |> (//) availableWidth
          |> toString
      languageNames =
          model.displayLanguages
          |> List.map (\lang -> viewConceptLanguageHeader languageColumnSize lang)
    in
    Table.table [ css "table-layout" "fixed", css "width" "100%" ]
        -- Table.table [css "table-layout" "fixed", css "width" "100%"]
        [ Table.thead
            []
            [ Table.tr [] (List.append descriptions languageNames)
              ]
        , Table.tbody []
            (rows
                |> List.indexedMap (\idx item -> ConceptDetail.viewConceptItem idx item model.mdl )
            )
        ]

viewConceptLanguageHeader : String -> String -> Html msg
viewConceptLanguageHeader size name =
    Table.th [css "text-align" "left", css "width" size][showText div Typo.body2 name]

viewFullConcepts : Model -> Html Msg
viewFullConcepts model =
    case model.concepts of
        NotAsked ->
            text "Initialising."

        Loading ->
            text "Loading."

        Failure err ->
            text ("Error: " ++ toString err)

        Success data ->
            viewFullConceptSuccess model data


viewFullConceptSuccess : Model -> List Concept -> Html Msg
viewFullConceptSuccess model data =
    data
    |> List.map (\item -> viewFullConcept item)
    |> div []


viewFullConcept : Concept -> Html Msg
viewFullConcept concept =
        grid [ Options.css "max-width" "1280px" ]
            [ cell
                [ size All 12
                , Options.css "padding" "6px 4px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                , Options.css "align-items" "left"
                ]
                [ showText div Typo.headline concept.name
                ]
            , cell
                [ size All 6
                , Options.css "padding" "6px 4px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                , Options.css "align-items" "left"
                ]
                [ viewConceptLanguageCodeTable concept.languageImplementations
                ]
            , cell
                [ size All 6
                -- , Elevation.e2
                , Options.css "padding" "6px 4px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                , Options.css "align-items" "stretch"
                , Options.css "justify-content" "flex-start"
                , Options.css "align-content" "stretch"
                ]
                [ viewConceptNote concept.notes
                , viewConceptLinks concept.links
                ]
            , cell
                [ size All 12
                , Options.css "padding" "6px 4px"
                , Options.css "display" "flex"
                , Options.css "flex-direction" "column"
                , Options.css "align-items" "left"
                ]
                [ viewConceptLanguageExamples concept.languageImplementations
                ]
            ]

viewConceptNote : Maybe String -> Html Msg
viewConceptNote note =
            case note of
              Just note_ ->
                Options.div
                [ Elevation.e4
                , css "height" "196px"
                , css "flex" "1 1 auto"
                , css "overflow" "auto"
                , css "border-radius" "2px"
                , css "width"  "528px"
                -- , css "margin-top" "4rem"
                , css "padding" "16px 16px 16px 16px"
                ]
                [ showText div Typo.caption "Notes"
                , text note_ ]
              Nothing ->
                text ""

viewConceptLinks : List ConceptLink -> Html Msg
viewConceptLinks links =
            Options.div
            [ Elevation.e4
            , css "height" "196px"
            , css "flex" "1 1 auto"
            , css "overflow" "auto"
            , css "border-radius" "2px"
            , css "width"  "528px"
            -- , css "margin-top" "4rem"
            , css "padding" "16px 16px 16px 16px"
            ]
            [ showText div Typo.caption "Links"
            , div []
                    (links
                    |> List.map (\link -> text link.url)
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
                |> List.indexedMap (\idx item -> viewConceptLanguageCodeTableItem idx item )
            )
        ]

viewConceptLanguageCodeTableItem : Int -> LanguageImplementation -> Html Msg
viewConceptLanguageCodeTableItem index language =
    Table.tr
        []
        [ Table.td [ css "text-align" "left" ] [ text language.language]
        , Table.td [ css "text-align" "left" ] [ text language.code ]
        ]


viewConceptLanguageExamples : List LanguageImplementation -> Html Msg
viewConceptLanguageExamples languages =
            Options.div
            [ --Elevation.e4
            -- , css "height" "196px"
             css "flex" "1 1 auto"
            , css "overflow" "auto"
            , css "border-radius" "2px"
            -- , css "width"  "528px"
            , css "margin-top" "2rem"
            , css "padding" "16px 16px 16px 16px"
            ]
            [ showText div Typo.caption "Examples"
            , div []
                (languages
                |> List.map (\language -> viewLanguageConceptExample language)
                )
            ]
    -- languages
    -- |> List.map (\language -> viewLanguageConceptExample language)


viewLanguageConceptExample : LanguageImplementation -> Html Msg
viewLanguageConceptExample language =
    case language.example of
        Just example ->
          viewLanguageExampleWrapper language.language example
        Nothing ->
          text ""


viewLanguageExampleWrapper : String -> String -> Html Msg
viewLanguageExampleWrapper name insideHtml =
            Options.div
            [ Elevation.e4
            -- , css "height" "196px"
            , css "flex" "1 1 auto"
            , css "overflow" "auto"
            , css "border-radius" "2px"
            -- , css "width"  "528px"
            -- , css "margin-top" "4rem"
            , css "padding" "16px 16px 16px 16px"
            ]
            [ showText div Typo.caption name
            -- , showText div Typo.body1 insideHtml
            , format "elm" [] insideHtml
            ]

format : String -> List (Options.Property c m) -> String -> Html m
format language options str =
    Options.styled
        (Markdown.toHtmlWith Markdown.defaultOptions)
        (Options.many
            [ css "overflow" "auto"
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
