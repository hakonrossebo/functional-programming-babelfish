module Pages.Babelfish.Helpers exposing (..)

import Regex

createConceptNameId : String -> String
createConceptNameId name =
    name
    |> Regex.replace Regex.All (Regex.regex "[ ]") (\_ -> "_")
