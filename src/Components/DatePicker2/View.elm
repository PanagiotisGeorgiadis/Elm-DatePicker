module Components.DatePicker2.View exposing (view)

-- import Utils.Html.Attributes as Attributes

import Components.DatePicker2.Update exposing (DateLimit(..), Model, Msg(..), ViewType(..))
import Components.MonthPicker as MonthPicker
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick)
import Utils.DateTime exposing (getMonthInt)
import Utils.Maybe as Maybe
import Utils.Time as Time


view : Model -> Html Msg
view model =
    case model.viewType of
        Single ->
            let
                ( isPreviousButtonActive, isNextButtonActive ) =
                    case model.dateLimit of
                        DateLimit { minDate, maxDate } ->
                            let
                                primaryDateMonthInt =
                                    getMonthInt model.primaryDate
                            in
                            ( getMonthInt minDate < primaryDateMonthInt
                            , getMonthInt maxDate > primaryDateMonthInt
                            )

                        NoLimit _ ->
                            ( True
                            , True
                            )

                pickerConfig =
                    { date = model.primaryDate
                    , nextButtonHandler = getNextButtonAction isNextButtonActive
                    , previousButtonHandler = getPreviousButtonAction isPreviousButtonActive
                    }
            in
            div [ class "single-calendar-view" ]
                [ MonthPicker.singleMonthPickerView2 pickerConfig
                , calendarView model
                ]

        Double ->
            let
                nextDate =
                    DateTime.incrementMonth model.primaryDate

                nextModel =
                    { model | primaryDate = nextDate }

                ( isPreviousButtonActive, isNextButtonActive ) =
                    case model.dateLimit of
                        DateLimit { minDate, maxDate } ->
                            ( getMonthInt minDate < getMonthInt model.primaryDate
                            , getMonthInt maxDate > getMonthInt nextDate
                            )

                        NoLimit _ ->
                            ( True
                            , True
                            )

                pickerConfig =
                    { date = model.primaryDate
                    , nextButtonHandler = getNextButtonAction isNextButtonActive
                    , previousButtonHandler = getPreviousButtonAction isPreviousButtonActive
                    }
            in
            div [ class "double-calendar-view" ]
                [ MonthPicker.doubleMonthPickerView2 pickerConfig
                , calendarView model
                , calendarView nextModel
                ]


calendarView : Model -> Html Msg
calendarView model =
    let
        monthDates =
            DateTime.getDatesInMonth model.primaryDate

        datesHtml =
            List.map (dateHtml model) monthDates

        precedingWeekdaysCount =
            case getFirstDayOfTheMonth model.primaryDate of
                Just firstDayOfTheMonth ->
                    Time.precedingWeekdays (DateTime.getWeekday firstDayOfTheMonth)

                Nothing ->
                    0

        precedingDatesHtml =
            List.repeat precedingWeekdaysCount emptyDateHtml

        followingDates =
            totalCalendarCells - precedingWeekdaysCount - List.length monthDates

        followingDatesHtml =
            List.repeat followingDates emptyDateHtml
    in
    div [ class "calendar" ]
        [ weekdaysHtml
        , div [ class "calendar_" ]
            (precedingDatesHtml ++ datesHtml ++ followingDatesHtml)
        ]


{-| Extract to another file as a common view fragment
-}
weekdaysHtml : Html Msg
weekdaysHtml =
    div [ class "weekdays" ]
        [ span [] [ text "Su" ]
        , span [] [ text "Mo" ]
        , span [] [ text "Tu" ]
        , span [] [ text "We" ]
        , span [] [ text "Th" ]
        , span [] [ text "Fr" ]
        , span [] [ text "Sa" ]
        ]


{-| Extract to another file as a common view fragment
-}
getFirstDayOfTheMonth : DateTime -> Maybe DateTime
getFirstDayOfTheMonth date =
    DateTime.fromRawParts
        { day = 1
        , month = DateTime.getMonth date
        , year = DateTime.getYear date
        }
        { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }


dateHtml : Model -> DateTime -> Html Msg
dateHtml ({ today, selectedDate } as model) date =
    let
        fullDateString =
            Time.toHumanReadableDate date

        ( isToday, isPastDate ) =
            ( areDatesEqual today date
            , DateTime.compareDates today date == GT
            )

        isSelected =
            Maybe.mapWithDefault (areDatesEqual date) False selectedDate

        isDisabledDate =
            checkIfDisabled model date

        dateClassList =
            [ ( "date", True )
            , ( "today", isToday )
            , ( "selected", isSelected )
            , ( "disabled", isDisabledDate )
            ]
    in
    if isDisabledDate then
        span
            [ classList dateClassList
            , title fullDateString
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]

    else
        span
            [ classList dateClassList
            , title fullDateString
            , onClick (SelectDate date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]


areDatesEqual : DateTime -> DateTime -> Bool
areDatesEqual lhs rhs =
    DateTime.compareDates lhs rhs == EQ


{-| Extract to another file as a common view fragment
-}
emptyDateHtml : Html msg
emptyDateHtml =
    span [ class "empty-date" ] []


{-| Checks if a Date on the DatePicker is a disabled one based on the specified date limitations.
-}
checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled { today, dateLimit } date =
    let
        isPastDate =
            DateTime.compareDates today date == GT
    in
    case dateLimit of
        NoLimit { disablePastDates } ->
            disablePastDates && isPastDate

        DateLimit { minDate, maxDate } ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || areDatesEqual minDate date)
                        && (DateTime.compareDates maxDate date == GT || areDatesEqual maxDate date)
            in
            not isPartOfTheConstraint


getNextButtonAction : Bool -> Maybe Msg
getNextButtonAction isButtonActive =
    if isButtonActive then
        Just NextMonth

    else
        Nothing


getPreviousButtonAction : Bool -> Maybe Msg
getPreviousButtonAction isButtonActive =
    if isButtonActive then
        Just PreviousMonth

    else
        Nothing


{-| Extract to another file as a common view fragment

    6 rows in total on the calendar
    7 columns on the calendar
    6 \* 7 = 42 is the total count of cells.

-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7
