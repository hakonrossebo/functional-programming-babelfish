module Routing.Router exposing (..)

import Material.Snackbar as Snackbar
import Navigation exposing (Location)
import Html exposing (..)
import Html.Attributes exposing (href)
import Types exposing (Route(..), TacoUpdate(..), Taco, SharedMsg(..))
import Routing.Helpers exposing (parseLocation, reverseRoute, fromTabToRoute)
import Pages.Babelfish.Babelfish as Babelfish
import Pages.About.About as About
import Material
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Material.Icon as Icon
import Material.Color as Color
import Material.Dialog as Dialog
import Material.Button as Button
import Material.Options as Options exposing (css, cs, when)


styles : String
styles =
    """\x0D
   .demo-options .mdl-checkbox__box-outline {\x0D
      border-color: rgba(255, 255, 255, 0.89);\x0D
    }\x0D
\x0D
   .mdl-layout__drawer {\x0D
      border: none !important;\x0D
   }\x0D
\x0D
   .mdl-layout__drawer .mdl-navigation__link:hover {\x0D
      background-color: #00BCD4 !important;\x0D
      color: #37474F !important;\x0D
    }\x0D
   """


type alias Model =
    { mdl : Material.Model
    , selectedTab : Int
    , snackbar : Snackbar.Model (Maybe Msg)
    , route : Route
    , babelfishModel : Babelfish.Model
    }


type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | UrlChange Location
    | SelectTab Int
    | NavigateTo Route
    | BabelfishMsg Babelfish.Msg


subs : Model -> Sub Msg
subs model =
    case model.route of
        RouteBabelfish ->
            Sub.map BabelfishMsg (Babelfish.subs model.babelfishModel)

        RouteAbout ->
            Sub.none

        NotFoundRoute ->
            Sub.none

init : Location -> Taco -> ( Model, Cmd Msg )
init location taco =
    let
        ( babelfishModel, babelfishCmd ) =
            Babelfish.init taco
    in
        ( { mdl = Material.model
          , selectedTab = 0
          , snackbar = Snackbar.model
          , babelfishModel = babelfishModel
          , route = parseLocation location
          }
        , Cmd.batch [Cmd.map BabelfishMsg babelfishCmd]
        )


update : Msg -> Model -> ( Model, Cmd Msg, TacoUpdate )
update msg model =
    case msg of
        Mdl msg_ ->
            let
                ( mdlModel, mdlCmd ) =
                    Material.update Mdl msg_ model
            in
                ( mdlModel, mdlCmd, NoUpdate )

        SelectTab k ->
            ( { model | selectedTab = k }, calculateNavigateUrlMessage k, NoUpdate )

        Snackbar msg_ ->
            let
                ( snackbar, snackCmd ) =
                    Snackbar.update msg_ model.snackbar
            in
                ( { model | snackbar = snackbar }, Cmd.map Snackbar snackCmd, NoUpdate )

        UrlChange location ->
            let
                ( snackModel, snackCmd ) =
                    Snackbar.add (Snackbar.toast Nothing "Url changed") model.snackbar
            in
                ( { model | route = parseLocation location, snackbar = snackModel }
                , Cmd.batch
                    [ Cmd.map Snackbar snackCmd
                    ]
                , NoUpdate
                )

        NavigateTo route ->
            ( model
            , Navigation.newUrl (reverseRoute route)
            , NoUpdate
            )

        BabelfishMsg babelfishMsg ->
            updateBabelfish model babelfishMsg

calculateNavigateUrlMessage : Int -> Cmd Msg
calculateNavigateUrlMessage tabIndex =
    fromTabToRoute tabIndex
        |> reverseRoute
        |> Navigation.newUrl



updateBabelfish : Model -> Babelfish.Msg -> ( Model, Cmd Msg, TacoUpdate )
updateBabelfish model babelfishMsg =
    let
        ( nextBabelfishModel, babelfishCmd, sharedMsg ) =
            Babelfish.update babelfishMsg model.babelfishModel
    in
        ( { model | babelfishModel = nextBabelfishModel }
        , Cmd.map BabelfishMsg babelfishCmd
        , NoUpdate
        )
        |> addSharedMsgToUpdate sharedMsg

addSharedMsgToUpdate : SharedMsg -> (Model, Cmd Msg, TacoUpdate) -> (Model, Cmd Msg, TacoUpdate)
addSharedMsgToUpdate sharedMsg (model, msg, tacoUpdate) =
      case sharedMsg of
        CreateSnackbarToast toastMessage ->
            let
                ( snackModel, snackCmd ) =
                    Snackbar.add (Snackbar.toast Nothing toastMessage) model.snackbar
            in
                ( { model | snackbar = snackModel }
                , Cmd.batch
                    [ Cmd.map Snackbar snackCmd
                    , msg
                    ]
                , tacoUpdate
                )

        NoSharedMsg ->
          (model, msg, tacoUpdate)




view : Taco -> Model -> Html Msg
view taco model =
    div [] <|
        [ Options.stylesheet styles
        , Layout.render Mdl
            model.mdl
            [ Layout.selectedTab model.selectedTab
            , Layout.onSelectTab SelectTab
            , Layout.fixedHeader
              -- , Layout.fixedDrawer
              -- , Layout.fixedTabs
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = [ viewHeader taco model ]
            , drawer = [ drawerHeader model, viewDrawer model ]
            -- , tabs = ( tabTitles, [] )
            , tabs = ( [], [] )
            , main =
                [ pageView taco model
                , Snackbar.view model.snackbar |> map Snackbar
                ]
            }
        , helpDialog model
        ]


viewHeader : Taco -> Model -> Html Msg
viewHeader taco model =
    Layout.row
        [ Color.background <| Color.color Color.Grey Color.S100
        , Color.text <| Color.color Color.Grey Color.S900
        ]
        [ Layout.title [] [ text "Functional programming babelfish" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                [Layout.href "https://github.com/hakonrossebo/functional-programming-babelfish"]
                [ span [] [ text "Fork me on Github"] ]
            ]
        ]


type alias MenuItem =
    { text : String
    , iconName : String
    , route : Types.Route
    }



--todo-refactor


tabTitles : List (Html Msg)
tabTitles =
    [ text "Cheat sheet", text "About"]


menuItems : List MenuItem
menuItems =
    [ { text = "Cheat sheet", iconName = "dashboard", route = RouteBabelfish }
    , { text = "About", iconName = "dashboard", route = RouteAbout }
    ]


viewDrawerMenuItem : Model -> MenuItem -> Html Msg
viewDrawerMenuItem model menuItem =
    Layout.link
        [ Options.onClick (NavigateTo menuItem.route)
        , when ((model.route) == menuItem.route) (Color.background <| Color.color Color.BlueGrey Color.S600)
        , Options.css "color" "rgba(255, 255, 255, 0.56)"
        , Options.css "font-weight" "500"
        ]
        [ Icon.view menuItem.iconName
            [ Color.text <| Color.color Color.BlueGrey Color.S500
            , Options.css "margin-right" "32px"
            ]
        , text menuItem.text
        ]


viewDrawer : Model -> Html Msg
viewDrawer model =
    Layout.navigation
        [ Color.background <| Color.color Color.BlueGrey Color.S800
        , Color.text <| Color.color Color.BlueGrey Color.S50
        , Options.css "flex-grow" "1"
        ]
    <|
        (List.map (viewDrawerMenuItem model) menuItems)


drawerHeader : Model -> Html Msg
drawerHeader model =
    Options.styled Html.header
        [ css "display" "flex"
        , css "box-sizing" "border-box"
        , css "justify-content" "flex-end"
        , css "padding" "16px"
        , css "height" "151px"
        , css "flex-direction" "column"
        , cs "demo-header"
        , Color.background <| Color.color Color.BlueGrey Color.S900
        , Color.text <| Color.color Color.BlueGrey Color.S50
        ]
        [ Options.styled Html.img
            [ Options.attribute <| Html.Attributes.src "images/elm.png"
            , css "width" "48px"
            , css "height" "48px"
            , css "border-radius" "24px"
            ]
            []
        , Options.styled Html.div
            [ css "display" "flex"
            , css "flex-direction" "row"
            , css "align-items" "center"
            , css "width" "100%"
            , css "position" "relative"
            ]
            [ Layout.spacer
            ]
        ]


pageView : Taco -> Model -> Html Msg
pageView taco model =
    case model.route of
        RouteBabelfish ->
            Babelfish.view taco model.babelfishModel
                |> Html.map BabelfishMsg

        RouteAbout ->
            About.view taco

        NotFoundRoute ->
            h1 [] [ text "404 :(" ]


helpDialog : Model -> Html Msg
helpDialog model =
    Dialog.view
        []
        [ Dialog.title [] [ text "About" ]
        , Dialog.content []
            [ Html.p []
                [ text "Empty dialog" ]
            , Html.p []
                [ text "Place text here" ]
            ]
        , Dialog.actions []
            [ Options.styled Html.span
                [ Dialog.closeOn "click" ]
                [ Button.render Mdl
                    [ 5, 1, 6 ]
                    model.mdl
                    [ Button.ripple
                    ]
                    [ text "Close" ]
                ]
            ]
        ]
