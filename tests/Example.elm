module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tests.Calendar as Calendar
import Tests.Clock as Clock
import Tests.DateTime as DateTime


suite : Test
suite =
    -- todo "Implement our first test. See https://package.elm-lang.org/packages/elm-explorations/test/latest for how to do this!"
    describe "DateTime Tests"
        -- [ describe "String.reverse"
        --     [ test "has no effect on palindrome"
        --         (\_ ->
        --             let
        --                 pallindrome =
        --                     "hannah"
        --             in
        --             Expect.equal pallindrome (String.reverse pallindrome)
        --         )
        --     , test "has no effect on empty string"
        --         (\_ ->
        --             let
        --                 emptyString =
        --                     ""
        --             in
        --             Expect.equal emptyString (String.reverse emptyString)
        --         )
        --     , test "reverses a known string"
        --         (\_ ->
        --             Expect.equal "GFEDCBA" (String.reverse "ABCDEFG")
        --         )
        --     ]
        -- , describe "One Thing Suite" oneThingSuite
        -- ]
        [ Calendar.suite
        , Clock.suite
        , DateTime.suite
        ]
