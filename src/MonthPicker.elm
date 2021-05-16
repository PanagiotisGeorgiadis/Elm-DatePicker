module MonthPicker exposing
    ( doubleMonthPickerView
    , singleMonthPickerView
    )

import DatePicker.I18n exposing (I18n, TextMode(..))
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
    , todayButtonHandler : Maybe msg
    , i18n : I18n
    }


singleMonthPickerView : MonthPickerConfig msg -> Html msg
singleMonthPickerView { date, previousButtonHandler, nextButtonHandler, todayButtonHandler, i18n } =
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
        , span [ class "month-name" ] [ text (monthPickerText i18n date) ]
        , nextButtonHtml
        , todayButtonHtml i18n.todayButtonText todayButtonHandler
        ]


doubleMonthPickerView : MonthPickerConfig msg -> Html msg
doubleMonthPickerView { date, previousButtonHandler, nextButtonHandler, todayButtonHandler, i18n } =
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
            , span [ class "month-name" ] [ text (monthPickerText i18n date) ]
            ]
        , div [ class "next-month" ]
            [ span [ class "month-name" ] [ text (monthPickerText i18n nextMonthDate) ]
            , nextButtonHtml
            ]
        , todayButtonHtml i18n.todayButtonText todayButtonHandler
        ]


monthPickerText : I18n -> DateTime -> String
monthPickerText i18n date =
    let
        ( month, year ) =
            ( DateTime.getMonth date
            , DateTime.getYear date
            )
    in
    i18n.monthToString Full month ++ " " ++ String.fromInt year


todayButtonHtml : String -> Maybe msg -> Html msg
todayButtonHtml todayButtonText msg =
    case msg of
        Just m ->
            div [ class "today-button", onClick m ] [ text todayButtonText ]

        Nothing ->
            text ""
