module TimePicker.View exposing (view)

import Html exposing (Html)
import TimePicker.Internal.Update exposing (Model, Msg)
import TimePicker.Internal.View as Internal


{-| The TimePicker view.
-}
view : Model -> Html Msg
view =
    Internal.view
