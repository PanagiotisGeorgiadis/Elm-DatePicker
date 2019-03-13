module Components.DatePicker.View exposing (view)

import Components.DatePicker.Internal.View as Internal
import Components.DatePicker.Update exposing (Model, Msg)
import Html exposing (Html)


{-| The DatePicker view.
-}
view : Model -> Html Msg
view =
    Internal.view
