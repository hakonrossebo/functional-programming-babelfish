module Pages.Babelfish.Helpers exposing (..)

import Material.Typography as Typo
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import Html exposing (Html, text, div, span, p, a)
import Regex

createConceptNameId : String -> String
createConceptNameId name =
    name
    |> Regex.replace Regex.All (Regex.regex "[ ]") (\_ -> "_")

showText : (List (Html.Attribute m) -> List (Html msg) -> a) -> Options.Property c m -> String -> a
showText elementType displayStyle text_ =
    Options.styled elementType [ displayStyle, Typo.left ] [ text text_ ]
