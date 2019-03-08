module Components.MonthPicker exposing
    ( doubleMonthPickerView
    , singleMonthPickerView
    )

import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Icons
import Utils.Time as Time


type alias MonthPickerConfig msg =
    { date : DateTime
    , previousButtonHandler : Maybe msg
    , nextButtonHandler : Maybe msg
    , todayButtonHandler : msg
    }


singleMonthPickerView : MonthPickerConfig msg -> Html msg
singleMonthPickerView { date, previousButtonHandler, nextButtonHandler, todayButtonHandler } =
    let
        previousButtonHtml =
            case previousButtonHandler of
                Just action ->
                    div [ class "action", onClick action ] [ Icons.triangle Icons.Left (Icons.Size "15" "15") ]

                Nothing ->
                    div [ class "action disabled" ] [ Icons.triangle Icons.Left (Icons.Size "15" "15") ]

        nextButtonHtml =
            case nextButtonHandler of
                Just action ->
                    div [ class "action", onClick action ] [ Icons.triangle Icons.Right (Icons.Size "15" "15") ]

                Nothing ->
                    div [ class "action disabled" ] [ Icons.triangle Icons.Right (Icons.Size "15" "15") ]
    in
    div [ class "single-month-picker" ]
        [ previousButtonHtml
        , span [ class "month-name" ] [ text (monthPickerText date) ]
        , nextButtonHtml
        , todayButtonHtml todayButtonHandler
        ]


doubleMonthPickerView : MonthPickerConfig msg -> Html msg
doubleMonthPickerView { date, previousButtonHandler, nextButtonHandler, todayButtonHandler } =
    let
        nextMonthDate =
            DateTime.incrementMonth date

        previousButtonHtml =
            case previousButtonHandler of
                Just action ->
                    div [ class "action", onClick action ] [ Icons.triangle Icons.Left (Icons.Size "15" "15") ]

                Nothing ->
                    div [ class "action disabled" ] [ Icons.triangle Icons.Left (Icons.Size "15" "15") ]

        nextButtonHtml =
            case nextButtonHandler of
                Just action ->
                    div [ class "action", onClick action ] [ Icons.triangle Icons.Right (Icons.Size "15" "15") ]

                Nothing ->
                    div [ class "action disabled" ] [ Icons.triangle Icons.Right (Icons.Size "15" "15") ]
    in
    div [ class "double-month-picker" ]
        [ div [ class "previous-month" ]
            [ previousButtonHtml
            , span [ class "month-name" ] [ text (monthPickerText date) ]
            ]
        , div [ class "next-month" ]
            [ span [ class "month-name" ] [ text (monthPickerText nextMonthDate) ]
            , nextButtonHtml
            ]
        , todayButtonHtml todayButtonHandler
        ]


monthPickerText : DateTime -> String
monthPickerText date =
    let
        ( month, year ) =
            ( DateTime.getMonth date
            , DateTime.getYear date
            )
    in
    Time.monthToString month ++ " " ++ String.fromInt year


todayButtonHtml : msg -> Html msg
todayButtonHtml msg =
    div [ class "today-button", onClick msg ] [ text "Today" ]
