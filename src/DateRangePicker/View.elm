module DateRangePicker.View exposing (view)

import DateRangePicker.Internal.View as Internal
import DateRangePicker.Update exposing (Model, Msg)
import Html exposing (Html)


{-| The DateRangePicker view.
-}
view : Model -> Html Msg
view =
    Internal.view
