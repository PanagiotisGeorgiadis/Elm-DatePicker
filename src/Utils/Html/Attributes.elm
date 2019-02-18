module Utils.Html.Attributes exposing (none)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode as Encode


none : Attribute msg
none =
    property "" Encode.null
