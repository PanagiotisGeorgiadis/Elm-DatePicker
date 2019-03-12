module Components.TimePicker.Internal.View exposing (view)

import Components.TimePicker.Internal.Update exposing (Model(..), Msg(..))
import Components.TimePicker.Types exposing (PickerType(..), TimeParts(..))
import Html exposing (Html, div, input, span, text)
import Html.Attributes exposing (class, maxlength, value)
import Html.Events exposing (onBlur, onClick, onInput)
import Icons


view : Model -> Html Msg
view ((Model { pickerType }) as model) =
    case pickerType of
        HH _ ->
            div [ class "time-picker" ]
                [ hourPicker model
                ]

        HH_MM _ ->
            div [ class "time-picker" ]
                [ hourPicker model
                , timeSegmentSeparator
                , minutePicker model
                ]

        HH_MM_SS _ ->
            div [ class "time-picker" ]
                [ hourPicker model
                , timeSegmentSeparator
                , minutePicker model
                , timeSegmentSeparator
                , secondsPicker model
                ]

        HH_MM_SS_MMMM _ ->
            div [ class "time-picker" ]
                [ hourPicker model
                , timeSegmentSeparator
                , minutePicker model
                , timeSegmentSeparator
                , secondsPicker model
                , millisSegmentSeparator
                , millisecondsPicker model
                ]


hourPicker : Model -> Html Msg
hourPicker (Model { hours }) =
    div [ class "hours-picker" ]
        [ div [ class "button", onClick (Increment Hours) ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput (InputHandler Hours)
            , onBlur (Update Hours hours)
            , value hours
            , maxlength 2
            ]
            []
        , div [ class "button", onClick (Decrement Hours) ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


minutePicker : Model -> Html Msg
minutePicker (Model { minutes }) =
    div [ class "minutes-picker" ]
        [ div [ class "button", onClick (Increment Minutes) ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput (InputHandler Minutes)
            , onBlur (Update Minutes minutes)
            , value minutes
            , maxlength 2
            ]
            []
        , div [ class "button", onClick (Decrement Minutes) ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


secondsPicker : Model -> Html Msg
secondsPicker (Model { seconds }) =
    div [ class "seconds-picker" ]
        [ div [ class "button", onClick (Increment Seconds) ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput (InputHandler Seconds)
            , onBlur (Update Seconds seconds)
            , value seconds
            , maxlength 2
            ]
            []
        , div [ class "button", onClick (Decrement Seconds) ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


millisecondsPicker : Model -> Html Msg
millisecondsPicker (Model { milliseconds }) =
    div [ class "milliseconds-picker" ]
        [ div [ class "button", onClick (Increment Milliseconds) ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput (InputHandler Milliseconds)
            , onBlur (Update Milliseconds milliseconds)
            , value milliseconds
            , maxlength 3
            ]
            []
        , div [ class "button", onClick (Decrement Milliseconds) ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


timeSegmentSeparator : Html Msg
timeSegmentSeparator =
    span [ class "time-separator no-select" ] [ text ":" ]


millisSegmentSeparator : Html Msg
millisSegmentSeparator =
    span [ class "time-separator no-select" ] [ text "." ]
