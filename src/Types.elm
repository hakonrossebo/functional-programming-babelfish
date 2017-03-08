module Types exposing (..)

import Time exposing (Time)


type alias Taco =
    { currentTime : Time
    , availableLanguages : List Language
    }


type Route
    = RouteBabelfish
    | RouteAbout
    | NotFoundRoute


type TacoUpdate
    = NoUpdate
    | UpdateTime Time
    | UpdateAvailableLanguages (List Language)


type SharedMsg
    = CreateSnackbarToast String
    | NoSharedMsg


type alias Language =
    { name : String
    , languageCode : String
    }


type alias Concept =
    { name : String
    , description : String
    , index : Int
    , notes : Maybe String
    , languageImplementations : List LanguageImplementation
    , links : List ConceptLink
    }


type alias LanguageImplementation =
    { name : String
    , code : String
    , example : Maybe (List String)
    }


type alias ConceptLink =
    { url : String
    , description : String
    }
