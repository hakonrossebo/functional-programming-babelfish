module Main exposing (..)

import Navigation exposing (Location)
import Html exposing (..)
import Types exposing (..)
import Time exposing (Time)
import RemoteData exposing (RemoteData(..))
import Routing.Router as Router
import Http
import Decoders
import Material.Menu as Menu
import Material
import Material.Progress as Loading
import Material.Options as Options exposing (when, css, cs, Style, onClick)

main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    let
      childSubscriptions =
          case model.appState of
              Ready taco routerModel ->
                  Sub.map RouterMsg (Router.subs routerModel)
              NotReady _ ->
                  Sub.none
    in
      Sub.batch [ Time.every Time.minute TimeChange
                , childSubscriptions
                , Material.subscriptions Mdl model
                ]

type alias Model =
    { mdl : Material.Model
    , appState : AppState
    , location : Location
    }

type AppState
    = NotReady Time
    | Ready Taco Router.Model

type alias Flags =
    { currentTime : Time
    }


type Msg
    = Mdl (Material.Msg Msg)
    | UrlChange Location
    | TimeChange Time
    | RouterMsg Router.Msg
    | HandleAvailableLanguagesResponse (RemoteData.WebData (List Language))

init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( { mdl = Material.model
      , appState = NotReady flags.currentTime
      , location = location
      }
      , fetchAvailableLanguages
    )

fetchAvailableLanguages : Cmd Msg
fetchAvailableLanguages =
    let
      url = "available-languages.json"
      req =  Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson Decoders.decodeAvailableLanguages
        , timeout = Nothing
        , withCredentials = False
        }
    in
      req
      |> RemoteData.sendRequest
      |> Cmd.map HandleAvailableLanguagesResponse

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        TimeChange time ->
            updateTime model time

        HandleAvailableLanguagesResponse webData ->
            updateAvailableLanguages model webData

        UrlChange location ->
            updateRouter { model | location = location } (Router.UrlChange location)

        RouterMsg routerMsg ->
            updateRouter model routerMsg


updateTime : Model -> Time -> ( Model, Cmd Msg )
updateTime model time =
    case model.appState of
        NotReady _ ->
            ( { model | appState = NotReady time }
            , Cmd.none
            )

        Ready taco routerModel ->
            ( { model | appState = Ready (updateTaco taco (UpdateTime time)) routerModel }
            , Cmd.none
            )


updateRouter : Model -> Router.Msg -> ( Model, Cmd Msg )
updateRouter model routerMsg =
    case model.appState of
        Ready taco routerModel ->
            let
                nextTaco =
                    updateTaco taco tacoUpdate

                ( nextRouterModel, routerCmd, tacoUpdate ) =
                    Router.update routerMsg routerModel
            in
                ( { model | appState = Ready nextTaco nextRouterModel }
                , Cmd.map RouterMsg routerCmd
                )

        NotReady _ ->
            Debug.crash "Ooops. We got a sub-component message even though it wasn't supposed to be initialized?!?!?"


updateAvailableLanguages : Model -> RemoteData.WebData (List Language) -> ( Model, Cmd Msg )
updateAvailableLanguages model webData =
    case webData of
        Failure _ ->
            Debug.crash "OMG CANT EVEN DOWNLOAD."

        Success languages ->
            case model.appState of
                NotReady time ->
                    let
                        initTaco =
                            { currentTime = time
                            , availableLanguages = languages
                            }

                        ( initRouterModel, routerCmd ) =
                            Router.init model.location initTaco
                    in
                        ( { model | appState = Ready initTaco initRouterModel }
                        , Cmd.map RouterMsg routerCmd
                        )

                Ready taco routerModel ->
                    ( { model | appState = Ready (updateTaco taco (UpdateAvailableLanguages languages)) routerModel }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )

updateTaco : Taco -> TacoUpdate -> Taco
updateTaco taco tacoUpdate =
    case tacoUpdate of
        UpdateTime time ->
            { taco | currentTime = time }

        UpdateAvailableLanguages languages ->
            { taco | availableLanguages = Debug.log "languages" languages }

        NoUpdate ->
            taco

view : Model -> Html Msg
view model =
    case model.appState of
        Ready taco routerModel ->
            Router.view taco routerModel
                |> Html.map RouterMsg

        NotReady _ ->
          Options.div [ css "display" "flex"
                      , css "width" "100%"
                      , css "height" "100vh"
                      , css "align-items" "center"
                      , css "justify-content" "center"
                      ][Loading.indeterminate]
