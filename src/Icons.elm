module Icons exposing
    ( Direction(..)
    , Size
    , checkbox
    , chevron
    , triangle
    )

import Html exposing (Html)
import Svg exposing (Svg, path, polygon, svg)
import Svg.Attributes exposing (d, height, points, transform, viewBox, width)
import Utils.Html.Attributes as Attributes


type alias Size =
    { width : String
    , height : String
    }


type Direction
    = Up
    | Down
    | Left
    | Right


tickedCheckboxPath : Svg msg
tickedCheckboxPath =
    path [ d "M21.3333333,0 L2.66666667,0 C1.19333333,0 0,1.19333333 0,2.66666667 L0,21.3333333 C0,22.8066667 1.19333333,24 2.66666667,24 L21.3333333,24 C22.8066667,24 24,22.8066667 24,21.3333333 L24,2.66666667 C24,1.19333333 22.8066667,0 21.3333333,0 Z M10.276,18.276 C9.75466667,18.7973333 8.91066667,18.7973333 8.39066667,18.276 L4,13.8853333 C3.48,13.3653333 3.48,12.52 4,12 C4.52,11.48 5.36533333,11.48 5.88533333,12 L9.33333333,15.448 L18.1146667,6.66666667 C18.6346667,6.14666667 19.48,6.14666667 20,6.66666667 C20.52,7.18666667 20.52,8.032 20,8.552 L10.276,18.276 Z" ] []


blankCheckboxPath : Svg msg
blankCheckboxPath =
    path [ d "M2.66666667,0 C1.2092496,0 0,1.2092496 0,2.66666667 L0,21.3333333 C0,22.7907507 1.2092496,24 2.66666667,24 L21.3333333,24 C22.7907507,24 24,22.7907507 24,21.3333333 L24,2.66666667 C24,1.2092496 22.7907507,0 21.3333333,0 L2.66666667,0 Z M2,2 L22,2 L22,22 L2,22 L2,2 Z" ] []


checkbox : Size -> Bool -> Html msg
checkbox size isChecked =
    svg [ width size.width, height size.height, viewBox "0 0 24 24" ]
        [ if isChecked then
            tickedCheckboxPath

          else
            blankCheckboxPath
        ]


chevron : Direction -> Size -> Html msg
chevron direction size =
    svg [ width size.width, height size.height, viewBox "0 0 24 24" ]
        [ polygon
            [ points "2.82 4.59 12 13.75 21.18 4.59 24 7.41 12 19.41 0 7.41"
            , case direction of
                Up ->
                    transform "translate(12.000000, 12.000000) rotate(180.000000) translate(-12.000000, -12.000000)"

                Down ->
                    Attributes.none

                Left ->
                    transform "translate(12.000000, 12.000000) rotate(90.000000) translate(-12.000000, -12.000000)"

                Right ->
                    transform "translate(12.000000, 12.000000) scale(-1, 1) rotate(90.000000) translate(-12.000000, -12.000000)"
            ]
            []
        ]


triangle : Direction -> Size -> Html msg
triangle direction size =
    svg [ width size.width, height size.height, viewBox "0 0 24 24" ]
        [ polygon
            [ points "0 6 12 18 24 6"
            , case direction of
                Down ->
                    Attributes.none

                Up ->
                    transform "translate(12.000000, 12.000000) rotate(180.000000) translate(-12.000000, -12.000000)"

                Left ->
                    transform "translate(12.000000, 12.000000) rotate(90.000000) translate(-12.000000, -12.000000)"

                Right ->
                    transform "translate(12.000000, 12.000000) scale(-1, 1) rotate(90.000000) translate(-12.000000, -12.000000)"
            ]
            []
        ]
