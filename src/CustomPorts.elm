port module CustomPorts exposing (..)

import Models exposing (..)


port showChart : List String -> Cmd msg


port setUpdatedData : List String -> Cmd msg
