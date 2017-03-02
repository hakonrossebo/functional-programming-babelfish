module Pages.Babelfish.Messages exposing (..)

import Material
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)

type Msg
    = Mdl (Material.Msg Msg)
    | ConceptsResponse (WebData (List Concept))
    | SelectLanguage String String
    | ScrollToDomId String
