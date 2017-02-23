module Types exposing (..)
import Time exposing (Time)

type alias Taco =
    { currentTime : Time
    , userInfo : UserInformation
    }


type Route
    = RouteBabelfish
    | RouteAbout
    | NotFoundRoute

type TacoUpdate
    = NoUpdate
    | UpdateTime Time
    | UpdateUserInfo UserInformation

type SharedMsg
    = CreateSnackbarToast String
    | NoSharedMsg

type alias UserInformation =
    { name : String
    , username : String
    , options : String
    }


type alias Concept =
    { name: String
    , description : String
    , index : Int
    , notes : Maybe String
    , languageImplementations : List LanguageImplementation
    , links : List ConceptLink
  }

type alias LanguageImplementation =
    { language : String
    , code : String
    , example : Maybe String
  }

type alias ConceptLink =
    { url : String
    , description : String
  }

type alias RowLanguageImplementations = List String

type ConceptLanguagesViewModel
    = NotCreated
    | Created RowLanguageImplementations (List (RowLanguageImplementations, RowLanguageImplementations))
