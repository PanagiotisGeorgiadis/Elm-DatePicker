module DatePicker.View exposing (view)

import DatePicker.Internal.View as Internal
import DatePicker.Update exposing (Model, Msg)
import Html exposing (Html)


{-| The DatePicker view.
-}
view : Model -> Html Msg
view =
    Internal.view
