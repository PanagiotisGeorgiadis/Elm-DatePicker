module Components.TimePicker.View exposing (view)

import Components.TimePicker.Update exposing (Model, Msg(..), PickerType(..))
import Html exposing (Html, div, i, input, span, text)
import Html.Attributes exposing (class, maxlength, value)
import Html.Events exposing (onBlur, onClick, onInput)
import Icons


view : Model -> Html Msg
view ({ pickerType } as model) =
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
hourPicker { hoursDisplayValue } =
    div [ class "hours-picker" ]
        [ div [ class "button", onClick IncrementHours ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput HoursInputHandler
            , onBlur (UpdateHours hoursDisplayValue)
            , value hoursDisplayValue
            , maxlength 2
            ]
            []
        , div [ class "button", onClick DecrementHours ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


minutePicker : Model -> Html Msg
minutePicker { minutesDisplayValue } =
    div [ class "minutes-picker" ]
        [ div [ class "button", onClick IncrementMinutes ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput MinutesInputHandler
            , onBlur (UpdateMinutes minutesDisplayValue)
            , value minutesDisplayValue
            , maxlength 2
            ]
            []
        , div [ class "button", onClick DecrementMinutes ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


secondsPicker : Model -> Html Msg
secondsPicker { secondsDisplayValue } =
    div [ class "seconds-picker" ]
        [ div [ class "button", onClick IncrementSeconds ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput SecondsInputHandler
            , onBlur (UpdateSeconds secondsDisplayValue)
            , value secondsDisplayValue
            , maxlength 2
            ]
            []
        , div [ class "button", onClick DecrementSeconds ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


millisecondsPicker : Model -> Html Msg
millisecondsPicker { millisecondsDisplayValue } =
    div [ class "milliseconds-picker" ]
        [ div [ class "button", onClick IncrementMilliseconds ] [ Icons.chevron Icons.Up (Icons.Size "24" "24") ]
        , input
            [ class "time-input"
            , onInput MillisecondsInputHandler
            , onBlur (UpdateMilliseconds millisecondsDisplayValue)
            , value millisecondsDisplayValue
            , maxlength 3
            ]
            []
        , div [ class "button", onClick DecrementMilliseconds ] [ Icons.chevron Icons.Down (Icons.Size "24" "24") ]
        ]


timeSegmentSeparator : Html Msg
timeSegmentSeparator =
    span [ class "time-separator no-select" ] [ text ":" ]


millisSegmentSeparator : Html Msg
millisSegmentSeparator =
    span [ class "time-separator no-select" ] [ text "." ]
