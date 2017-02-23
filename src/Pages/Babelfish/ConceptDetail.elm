
module Pages.Babelfish.ConceptDetail exposing (..)
import Html exposing (Html, text, div, span, p, a)
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

viewConceptItem : Int -> (RowLanguageImplementations, RowLanguageImplementations) -> Material.Model -> Html msg
viewConceptItem idx (descRow, codeRow) outerMdl =
       let
         code =
           codeRow
           |> List.map (\row -> viewConceptLanguage row)
         desc =
           descRow
           |> List.map (\row -> viewConceptLanguageDescription row)
       in
          List.append desc code
          |> Table.tr []

viewConceptLanguageDescription : String -> Html msg
viewConceptLanguageDescription code =
    Table.td [css "text-align" "left", css "background-color" "#f6f6f6", cs "wrapword"][text code]

viewConceptLanguage : String -> Html msg
viewConceptLanguage code =
    Table.td [css "text-align" "left", cs "wrapword"][text code]
