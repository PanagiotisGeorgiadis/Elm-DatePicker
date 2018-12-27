module Components.MonthPicker exposing (DoubleMonthPickerConfig, SingleMonthPickerConfig, doubleMonthPickerView2, monthPickerText2, singleMonthPickerView2)

-- import DateTime.Calendar as Calendar

import DateTime.DateTime as DateTime exposing (DateTime)
import Html exposing (Html, div, i, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Time exposing (Month(..))
import Utils.Time as Time



-- type alias MonthPickerConfig msg =
--     { startYear : Int
--     , startMonth : Month
--     , previousButtonHandler : Maybe msg
--     , nextButtonHandler : Maybe msg
--     }


type alias SingleMonthPickerConfig msg =
    { date : DateTime

    -- You can also have that.
    -- , today : Maybe Calendar.Date
    , previousButtonHandler : Maybe msg
    , nextButtonHandler : Maybe msg

    -- , dateSelectionHandler : Maybe msg
    }



-- type alias MonthPickerConfig2 msg =
--     { date : Calendar.Date
--     -- You can also have that.
--     -- , today : Maybe Calendar.Date
--     , previousButtonHandler : Maybe msg
--     , nextButtonHandler : Maybe msg
--     }
-- singleMonthPickerView : MonthPickerConfig msg -> Html msg
-- singleMonthPickerView { startMonth, startYear } =
--     div [ class "single-month-picker" ]
--         [ i [ class "fa fa-caret-left previous-month-button" ] []
--         , span
--             [ class "month-name-placeholder" ]
--             [ text (monthPickerText startYear startMonth) ]
--         , i [ class "fa fa-caret-right next-month-button" ] []
--         ]


singleMonthPickerView2 : SingleMonthPickerConfig msg -> Html msg
singleMonthPickerView2 { date, previousButtonHandler, nextButtonHandler } =
    let
        previousButtonHtml =
            case previousButtonHandler of
                Just action ->
                    i [ class "fa fa-caret-left action", onClick action ] []

                Nothing ->
                    text ""

        nextButtonHtml =
            case nextButtonHandler of
                Just action ->
                    i [ class "fa fa-caret-right action", onClick action ] []

                Nothing ->
                    text ""
    in
    div [ class "single-month-picker" ]
        [ previousButtonHtml
        , span [ class "month-name" ] [ text (monthPickerText2 date) ]
        , nextButtonHtml
        ]



-- doubleMonthPickerView : MonthPickerConfig msg -> Html msg
-- doubleMonthPickerView { startMonth, startYear } =
--     let
--         nextMonth_ =
--             -- getNextMonth function should basically take a DateTime or a Calendar.Date in order to be precise.
--             nextMonth startMonth
--
--         nextYear =
--             case nextMonth_ of
--                 Jan ->
--                     startYear + 1
--
--                 _ ->
--                     startYear
--     in
--     div [ class "double-month-picker" ]
--         [ i [ class "fa fa-caret-left previous-month-button" ] []
--         , span
--             [ class "month-name-placeholder previous-month" ]
--             [ text (monthPickerText startYear startMonth) ]
--         , span
--             [ class "month-name-placeholder next-month" ]
--             [ text (monthPickerText nextYear nextMonth_) ]
--         , i [ class "fa fa-caret-right next-month-button" ] []
--         ]


type alias DoubleMonthPickerConfig msg =
    { date : DateTime

    -- You can also have that.
    -- , today : Maybe Calendar.Date
    , previousButtonHandler : Maybe msg
    , nextButtonHandler : Maybe msg

    -- , dateSelectionHandler : Maybe msg
    }


doubleMonthPickerView2 : DoubleMonthPickerConfig msg -> Html msg
doubleMonthPickerView2 { date, previousButtonHandler, nextButtonHandler } =
    let
        nextMonthDate =
            -- Calendar.getNextMonth date
            DateTime.getNextMonth date

        previousButtonHtml =
            case previousButtonHandler of
                Just action ->
                    i [ class "fa fa-caret-left action", onClick action ] []

                Nothing ->
                    text ""

        nextButtonHtml =
            case nextButtonHandler of
                Just action ->
                    i [ class "fa fa-caret-right action", onClick action ] []

                Nothing ->
                    text ""
    in
    div [ class "double-month-picker" ]
        [ div [ class "previous-month" ]
            [ previousButtonHtml
            , span [ class "month-name" ] [ text (monthPickerText2 date) ]
            ]
        , div [ class "next-month" ]
            [ span [ class "month-name" ] [ text (monthPickerText2 nextMonthDate) ]
            , nextButtonHtml
            ]
        ]



-- [ i [ class "fa fa-caret-left previous-month-button" ] []
-- , span
--     [ class "month-name-placeholder previous-month" ]
--     [ text (monthPickerText2 date) ]
-- , span
--     [ class "month-name-placeholder next-month" ]
--     [ text (monthPickerText2 nextMonthDate) ]
-- , i [ class "fa fa-caret-right next-month-button" ] []
-- ]
-- monthPickerText : Int -> Month -> String
-- monthPickerText year month =
--     monthToString month ++ " " ++ String.fromInt year


monthPickerText2 : DateTime -> String
monthPickerText2 date =
    let
        ( month, year ) =
            -- ( Calendar.getMonth date
            -- , Calendar.yearToInt (Calendar.getYear date)
            -- )
            ( DateTime.getMonth date
            , DateTime.getYearInt date
            )
    in
    Time.monthToString month ++ " " ++ String.fromInt year
