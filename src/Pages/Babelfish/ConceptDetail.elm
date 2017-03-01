
module Pages.Babelfish.ConceptDetail exposing (..)
import Html exposing (Html, text, div, span, p, a)
import Html.Attributes exposing (href)
import Material
import Json.Decode as Json exposing (field)
import Json.Encode
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import String
import Material.Table as Table
import Material.Icon as Icon
import Material.Tooltip as Tooltip
import Http exposing (Error)
import Types exposing (Concept, LanguageImplementation, RowLanguageImplementations)
import Dict
import Pages.Babelfish.Helpers exposing (..)

viewConceptItem : Int -> (RowLanguageImplementations, RowLanguageImplementations) -> Material.Model -> Html msg
viewConceptItem idx (descRow, codeRow) outerMdl =
       let
         code =
           codeRow
           |> List.map (\row -> viewConceptLanguage row)
         desc =
           descRow
           |> List.indexedMap (\idx row -> viewConceptLanguageDescription idx row)
       in
          List.append desc code
          |> Table.tr []

viewConceptLanguageDescription : Int -> String -> Html msg
viewConceptLanguageDescription idx descriptionText =
    let
      content =
        if idx == 99 then
          [a [href <| "#" ++ createConceptNameId descriptionText] [text descriptionText]]
        else
          [text descriptionText]
    in
    Table.td [css "text-align" "left", css "background-color" "#f6f6f6", cs "wrapword"] (content)

viewConceptLanguage : String -> Html msg
viewConceptLanguage code =
    Table.td [css "text-align" "left", cs "wrapword"][text code]
