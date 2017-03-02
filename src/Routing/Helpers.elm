module Routing.Helpers exposing (..)

import Navigation exposing (Location)
import UrlParser as Url exposing ((</>))
import Types exposing (..)


reverseRoute : Route -> String
reverseRoute route =
    case route of
        RouteAbout ->
            "#/about"

        RouteBabelfish ->
            "#/"

        _ ->
            "#/"


routeParser : Url.Parser (Route -> a) a
routeParser =
    Url.oneOf
        [ Url.map RouteBabelfish Url.top
        , Url.map RouteAbout (Url.s "about")
        , Url.map RouteBabelfish (Url.s "#/")
        ]


parseLocation : Location -> Route
parseLocation location =
    location
        |> Url.parseHash routeParser
        |> Maybe.withDefault NotFoundRoute


fromTabToRoute : Int -> Route
fromTabToRoute tabIndex =
    case tabIndex of
        0 ->
            RouteBabelfish

        1 ->
            RouteAbout

        _ ->
            RouteBabelfish


fromRouteToTab : Route -> Int
fromRouteToTab route =
    case route of
        RouteBabelfish ->
            0

        RouteAbout ->
            1

        _ ->
            0
