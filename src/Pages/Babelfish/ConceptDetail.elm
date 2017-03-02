
module Pages.Babelfish.ConceptDetail exposing (..)
import Html exposing (Html, text, div, span, p, a)
import Material
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import Material.Table as Table
import Material.Icon as Icon
import Material.Tooltip as Tooltip
import Types exposing (Concept, LanguageImplementation, RowLanguageImplementations)
import Pages.Babelfish.Helpers exposing (..)

viewConceptItem : Int -> (RowLanguageImplementations, RowLanguageImplementations) -> Material.Model -> (Material.Msg msg -> msg) -> (String -> msg) -> Html msg
viewConceptItem idx (descRow, codeRow) outerMdl mdlMsg jump =
       let
         code =
           codeRow
           |> List.map (\row -> viewConceptLanguage row)
         desc =
           descRow
           |> List.indexedMap (\idx row -> viewConceptLanguageDescription idx outerMdl row mdlMsg jump)
       in
          List.append desc code
          |> Table.tr []

viewConceptLanguageDescription : Int -> Material.Model -> String -> (Material.Msg msg -> msg) -> (String -> msg) -> Html msg
viewConceptLanguageDescription idx outerMdl descriptionText mdlMsg jump =
    let
      content =
        if idx == 0 then
          [ Button.render mdlMsg [1, idx] outerMdl
              [ Button.icon
              , Options.onClick (jump <| createConceptNameId descriptionText )
              ]
              [ Icon.view "zoom_in" [ Tooltip.attach mdlMsg [1, idx ] ], Tooltip.render mdlMsg [1, idx ] outerMdl [ ] [ text "Go to details" ] ]
          , text descriptionText
          ]
        else
          [text descriptionText]
    in
    Table.td [css "text-align" "left", css "background-color" "#f6f6f6", cs "wrapword"] (content)

viewConceptLanguage : String -> Html msg
viewConceptLanguage code =
    Table.td [css "text-align" "left", cs "wrapword"][text code]
