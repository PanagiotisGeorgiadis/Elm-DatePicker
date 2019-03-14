module DateRangePicker.View exposing (view)

{-| No Description Yet

@docs view

-}

import DateRangePicker.Internal.View as Internal
import DateRangePicker.Update exposing (Model, Msg)
import Html exposing (Html)


{-| The `DateRangePicker` view function.
-}
view : Model -> Html Msg
view =
    Internal.view
