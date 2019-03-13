module Components.DateRangePicker.View exposing (view)

import Components.DateRangePicker.Internal.View as Internal
import Components.DateRangePicker.Update exposing (Model, Msg)
import Html exposing (Html)


{-| The DateRangePicker view.
-}
view : Model -> Html Msg
view =
    Internal.view
