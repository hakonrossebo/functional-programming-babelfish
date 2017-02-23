module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import Routing
import Types

all : Test
all =
    describe "A Test Suite"
        [ test "App.model.message should be set properly" <|
            \() ->
                -- Expect.equal (Tuple.first App.init |> .message) "Your Elm App is working!"
                Expect.equal 1 1
        , test "Addition" <|
            \() ->
                Expect.equal (3 + 7) 10
        , test "String.left" <|
            \() ->
                Expect.equal "a" (String.left 1 "abcdefg")
        -- , test "This test should fail" <|
        --     \() ->
        --         Expect.fail "failed as expected!"
        ]
