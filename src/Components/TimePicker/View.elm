module Components.TimePicker.View exposing (view)

import Components.TimePicker.Internal.Update exposing (Model, Msg)
import Components.TimePicker.Internal.View as Internal
import Html exposing (Html)


view : Model -> Html Msg
view =
    Internal.view
