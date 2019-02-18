module Components.DateRangePicker.View exposing (view)

import Components.DateRangePicker.Update
    exposing
        ( ConstrainedModel
        , Constraints
        , DateConstrains(..)
        , Model
        , Model2(..)
        , Msg(..)
        , ViewType(..)
        , getPrimaryDate
        , getViewType
        )
import Components.MonthPicker as MonthPicker
import DateTime exposing (DateTime)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Models.Calendar exposing (isBetweenFutureLimit, isBetweenPastLimit)
import Utils.DateTime as DateTimeUtils
import Utils.Html.Attributes as Attributes
import Utils.Maybe as Maybe
import Utils.Time as Time



-- onMouseLeaveListener : Model -> Attribute Msg
-- onMouseLeaveListener model =
--     if model.showOnHover then
--         onMouseLeave ResetShadowDateRange
--
--     else
--         Attributes.none
--
-- view_ : Model -> Html Msg
-- view_ model =
--     let
--         pickerConfig =
--             case model.constrainedDate of
--                 Constrained { minDate, maxDate } ->
--                     let
--                         primaryDateMonthInt =
--                             DateTimeUtils.getMonthInt model.primaryDate
--
--                         previousButtonHandler =
--                             if DateTimeUtils.getMonthInt minDate < primaryDateMonthInt then
--                                 Just PreviousMonth
--
--                             else
--                                 Nothing
--                     in
--                     case model.viewType of
--                         Single ->
--                             { date = model.primaryDate
--                             , previousButtonHandler = previousButtonHandler
--                             , nextButtonHandler =
--                                 if DateTimeUtils.getMonthInt maxDate > primaryDateMonthInt then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--
--                         Double ->
--                             let
--                                 nextMonthInt =
--                                     DateTimeUtils.getMonthInt (DateTime.incrementMonth model.primaryDate)
--                             in
--                             { date = model.primaryDate
--                             , previousButtonHandler = previousButtonHandler
--                             , nextButtonHandler =
--                                 if DateTimeUtils.getMonthInt maxDate > nextMonthInt then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--
--                 Unconstrained ->
--                     case model.viewType of
--                         Single ->
--                             { date = model.primaryDate
--                             , previousButtonHandler =
--                                 if isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit then
--                                     Just PreviousMonth
--
--                                 else
--                                     Nothing
--                             , nextButtonHandler =
--                                 if isBetweenFutureLimit model.today model.primaryDate model.futureDatesLimit then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--
--                         Double ->
--                             { date = model.primaryDate
--                             , previousButtonHandler =
--                                 if isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit then
--                                     Just PreviousMonth
--
--                                 else
--                                     Nothing
--                             , nextButtonHandler =
--                                 if isBetweenFutureLimit model.today (DateTime.incrementMonth model.primaryDate) model.futureDatesLimit then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--     in
--     case model.viewType of
--         Single ->
--             div
--                 [ class "single-calendar-view"
--                 , onMouseLeave ResetShadowDateRange
--                 ]
--                 [ MonthPicker.singleMonthPickerView2 pickerConfig
--                 , calendarView model
--                 ]
--
--         Double ->
--             let
--                 nextModel =
--                     { model | primaryDate = DateTime.incrementMonth model.primaryDate }
--             in
--             div
--                 [ class "double-calendar-view"
--                 , onMouseLeave ResetShadowDateRange
--                 ]
--                 [ MonthPicker.doubleMonthPickerView2 pickerConfig
--                 , calendarView model
--                 , calendarView nextModel
--                 ]
--
--
-- view_ : Model -> Html Msg
-- view_ model =
--     case model.constrainedDate of
--         Constrained { minDate, maxDate } ->
--             let
--                 primaryDateMonthInt =
--                     DateTimeUtils.getMonthInt model.primaryDate
--
--                 previousButtonHandler =
--                     if DateTimeUtils.getMonthInt minDate < primaryDateMonthInt then
--                         Just PreviousMonth
--
--                     else
--                         Nothing
--             in
--             case model.viewType of
--                 Single ->
--                     let
--                         pickerConfig =
--                             { date = model.primaryDate
--                             , previousButtonHandler = previousButtonHandler
--                             , nextButtonHandler =
--                                 if DateTimeUtils.getMonthInt maxDate > primaryDateMonthInt then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--                     in
--                     div
--                         [ class "single-calendar-view"
--                         , onMouseLeave ResetShadowDateRange
--                         ]
--                         [ MonthPicker.singleMonthPickerView2 pickerConfig
--                         , calendarView model
--                         ]
--
--                 Double ->
--                     let
--                         nextDate =
--                             DateTime.incrementMonth model.primaryDate
--
--                         nextModel =
--                             { model | primaryDate = nextDate }
--
--                         pickerConfig =
--                             { date = model.primaryDate
--                             , previousButtonHandler = previousButtonHandler
--                             , nextButtonHandler =
--                                 if DateTimeUtils.getMonthInt maxDate > DateTimeUtils.getMonthInt nextDate then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--                     in
--                     div
--                         [ class "double-calendar-view"
--                         , onMouseLeave ResetShadowDateRange
--                         ]
--                         [ MonthPicker.doubleMonthPickerView2 pickerConfig
--                         , calendarView model
--                         , calendarView nextModel
--                         ]
--
--         Unconstrained ->
--             case model.viewType of
--                 Single ->
--                     let
--                         pickerConfig =
--                             { date = model.primaryDate
--                             , previousButtonHandler =
--                                 if isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit then
--                                     Just PreviousMonth
--
--                                 else
--                                     Nothing
--                             , nextButtonHandler =
--                                 if isBetweenFutureLimit model.today model.primaryDate model.futureDatesLimit then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--                     in
--                     div
--                         [ class "single-calendar-view"
--                         , onMouseLeave ResetShadowDateRange
--                         ]
--                         [ MonthPicker.singleMonthPickerView2 pickerConfig
--                         , calendarView model
--                         ]
--
--                 Double ->
--                     let
--                         nextDate =
--                             DateTime.incrementMonth model.primaryDate
--
--                         nextModel =
--                             { model | primaryDate = nextDate }
--
--                         pickerConfig =
--                             { date = model.primaryDate
--                             , previousButtonHandler =
--                                 if isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit then
--                                     Just PreviousMonth
--
--                                 else
--                                     Nothing
--                             , nextButtonHandler =
--                                 if isBetweenFutureLimit model.today nextDate model.futureDatesLimit then
--                                     Just NextMonth
--
--                                 else
--                                     Nothing
--                             }
--                     in
--                     div
--                         [ class "double-calendar-view"
--                         , onMouseLeave ResetShadowDateRange
--                         ]
--                         [ MonthPicker.doubleMonthPickerView2 pickerConfig
--                         , calendarView model
--                         , calendarView nextModel
--                         ]


getNextMonthAction : Bool -> Maybe Msg
getNextMonthAction isButtonActive =
    if isButtonActive then
        Just NextMonth

    else
        Nothing


getPreviousMonthAction : Bool -> Maybe Msg
getPreviousMonthAction isButtonActive =
    if isButtonActive then
        Just PreviousMonth

    else
        Nothing



-- singleCalendarView : Model -> Html Msg
-- singleCalendarView model =
--     let
--         ( isPreviousButtonActive, isNextButtonActive ) =
--             case model.constrainedDate of
--                 Constrained { minDate, maxDate } ->
--                     let
--                         primaryDateMonthInt =
--                             DateTimeUtils.getMonthInt model.primaryDate
--                     in
--                     ( DateTimeUtils.getMonthInt minDate < primaryDateMonthInt
--                     , DateTimeUtils.getMonthInt maxDate > primaryDateMonthInt
--                     )
--
--                 Unconstrained ->
--                     ( isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit
--                     , isBetweenFutureLimit model.today model.primaryDate model.futureDatesLimit
--                     )
--
--         pickerConfig =
--             { date = model.primaryDate
--             , nextButtonHandler =
--                 if isNextButtonActive then
--                     Just NextMonth
--
--                 else
--                     Nothing
--             , previousButtonHandler =
--                 if isPreviousButtonActive then
--                     Just PreviousMonth
--
--                 else
--                     Nothing
--             }
--     in
--     div
--         [ class "single-calendar-view"
--         , onMouseLeave ResetShadowDateRange
--         ]
--         [ MonthPicker.singleMonthPickerView2 pickerConfig
--         , calendarView model
--         ]
--
--
--
-- calendarView : Model -> Html Msg
-- calendarView model =
--     let
--         monthDates =
--             DateTime.getDatesInMonth model.primaryDate
--
--         datesHtml =
--             List.map (dateHtml model) monthDates
--
--         precedingWeekdaysCount =
--             case getFirstDayOfTheMonth model.primaryDate of
--                 Just firstDayOfTheMonth ->
--                     Time.precedingWeekdays (DateTime.getWeekday firstDayOfTheMonth)
--
--                 Nothing ->
--                     0
--
--         precedingDatesHtml =
--             List.repeat precedingWeekdaysCount emptyDateHtml
--
--         followingDates =
--             totalCalendarCells - precedingWeekdaysCount - List.length monthDates
--
--         followingDatesHtml =
--             List.repeat followingDates emptyDateHtml
--     in
--     div [ class "calendar" ]
--         [ weekdaysHtml
--         , div [ class "calendar_" ]
--             (precedingDatesHtml ++ datesHtml ++ followingDatesHtml)
--         ]
--
--
-- calendarView : Model2 -> Html Msg
-- calendarView model =
--     let
--         primaryDate =
--             getPrimaryDate model
--
--         monthDates =
--             DateTime.getDatesInMonth primaryDate
--
--         datesHtml =
--             -- List.map (dateHtml model) monthDates
--             case model of
--                 Constrained_ constraints model_ ->
--                     List.map (constrainedDateHtml model_ constraints) monthDates
--
--                 Unconstrained_ model_ ->
--                     -- List.map (dateHtml model_) monthDates
--                     []
--
--         precedingWeekdaysCount =
--             case getFirstDayOfTheMonth primaryDate of
--                 Just firstDayOfTheMonth ->
--                     Time.precedingWeekdays (DateTime.getWeekday firstDayOfTheMonth)
--
--                 Nothing ->
--                     0
--
--         precedingDatesHtml =
--             List.repeat precedingWeekdaysCount emptyDateHtml
--
--         followingDates =
--             totalCalendarCells - precedingWeekdaysCount - List.length monthDates
--
--         followingDatesHtml =
--             List.repeat followingDates emptyDateHtml
--     in
--     div [ class "calendar" ]
--         [ weekdaysHtml
--         , div [ class "calendar_" ]
--             (precedingDatesHtml ++ datesHtml ++ followingDatesHtml)
--         ]


getVisualRangeEdges : Model2 -> ( Maybe DateTime, Maybe DateTime )
getVisualRangeEdges m =
    let
        getRangeEdges { rangeStart, rangeEnd, shadowRangeEnd } =
            case shadowRangeEnd of
                Just end ->
                    sortMaybeDates rangeStart (Just end)

                Nothing ->
                    sortMaybeDates rangeStart rangeEnd
    in
    case m of
        Constrained_ _ model ->
            getRangeEdges model

        Unconstrained_ model ->
            getRangeEdges model


checkIfDisabled : Model2 -> DateTime -> Bool
checkIfDisabled m date =
    case m of
        Constrained_ { minDate, maxDate } _ ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || areDatesEqual minDate date)
                        && (DateTime.compareDates maxDate date == GT || areDatesEqual maxDate date)
            in
            not isPartOfTheConstraint

        Unconstrained_ { today, disablePastDates } ->
            let
                isPastDate =
                    DateTime.compareDates today date == GT
            in
            disablePastDates && isPastDate


isToday2 : Model2 -> DateTime -> Bool
isToday2 m date =
    case m of
        Constrained_ _ { today } ->
            areDatesEqual today date

        Unconstrained_ { today } ->
            areDatesEqual today date


dateHtml123 : Model2 -> DateTime -> Html Msg
dateHtml123 model date =
    let
        ( visualRangeStart, visualRangeEnd ) =
            getVisualRangeEdges model

        isPartOfTheDateRange =
            case ( visualRangeStart, visualRangeEnd ) of
                ( Just start, Just end ) ->
                    (DateTime.compareDates start date == LT)
                        && (DateTime.compareDates end date == GT)

                _ ->
                    False

        ( isStartOfTheDateRange, isEndOfTheDateRange ) =
            ( Maybe.mapWithDefault (areDatesEqual date) False visualRangeStart
            , Maybe.mapWithDefault (areDatesEqual date) False visualRangeEnd
            )

        isDisabled =
            checkIfDisabled model date

        dateClassList =
            [ ( "date", True )
            , ( "today", isToday2 model date )
            , ( "selected", isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "date-range", isPartOfTheDateRange )

            -- The "not isEndOfTheDateRange && visualRangeEnd /= Nothing" clause is added in order to fix a css bug.
            , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange && visualRangeEnd /= Nothing )

            -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
            , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )

            -- , ( "invalid-selection", isInvalidSelection )
            , ( "disabled", isDisabled )
            ]
    in
    if isDisabled then
        span
            [ classList dateClassList
            , title (Time.toHumanReadableDate date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]

    else
        span
            [ classList dateClassList
            , title (Time.toHumanReadableDate date)
            , onClick (SelectDate date)
            , onMouseOver (DateHoverDetected date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]


getMonthPickerHtml : Model2 -> Html Msg
getMonthPickerHtml m =
    case m of
        Constrained_ { minDate, maxDate } { primaryDate, viewType } ->
            let
                ( primaryDateMonthInt, nextDateMonthInt ) =
                    ( DateTimeUtils.getMonthInt primaryDate
                    , DateTimeUtils.getMonthInt (DateTime.incrementMonth primaryDate)
                    )

                getPickerConfig futureMonthInt =
                    { date = primaryDate
                    , nextButtonHandler = getNextMonthAction (DateTimeUtils.getMonthInt maxDate > futureMonthInt)
                    , previousButtonHandler = getPreviousMonthAction (DateTimeUtils.getMonthInt minDate < primaryDateMonthInt)
                    }
            in
            case viewType of
                Single ->
                    MonthPicker.singleMonthPickerView2 (getPickerConfig primaryDateMonthInt)

                Double ->
                    MonthPicker.doubleMonthPickerView2 (getPickerConfig nextDateMonthInt)

        Unconstrained_ { today, viewType, primaryDate, pastDatesLimit, futureDatesLimit } ->
            let
                getPickerConfig nextButtonDate =
                    { date = primaryDate
                    , nextButtonHandler = getNextMonthAction (isBetweenFutureLimit today nextButtonDate futureDatesLimit)
                    , previousButtonHandler = getPreviousMonthAction (isBetweenPastLimit today (DateTime.decrementMonth primaryDate) pastDatesLimit)
                    }
            in
            case viewType of
                Single ->
                    MonthPicker.singleMonthPickerView2 (getPickerConfig primaryDate)

                Double ->
                    MonthPicker.doubleMonthPickerView2 (getPickerConfig (DateTime.incrementMonth primaryDate))


view2 : Model2 -> Html Msg
view2 m =
    let
        monthPickerHtml =
            getMonthPickerHtml m

        viewType =
            getViewType m
    in
    case viewType of
        Single ->
            div
                [ class "single-calendar-view"
                , onMouseLeave ResetShadowDateRange
                ]
                [ monthPickerHtml

                -- , calendarView model
                , div [] [ text "implement the new calendarView function" ]
                ]

        Double ->
            div
                [ class "double-calendar-view"
                , onMouseLeave ResetShadowDateRange
                ]
                [ monthPickerHtml

                -- , calendarView model
                -- , calendarView { model | primaryDate = nextDate }
                , div [] [ text "implement the new calendarView function" ]
                , div [] [ text "implement the new calendarView function" ]
                ]



-- case m of
--     Constrained_ constraints model ->
--         let
--             primaryDateMonthInt =
--                 DateTimeUtils.getMonthInt model.primaryDate
--
--             getPickerConfig isNextButtonActive =
--                 { date = model.primaryDate
--                 , nextButtonHandler = getNextMonthAction isNextButtonActive
--                 , previousButtonHandler = getPreviousMonthAction (DateTimeUtils.getMonthInt constraints.minDate < primaryDateMonthInt)
--                 }
--         in
--         case model.viewType of
--             Single ->
--                 let
--                     pickerConfig =
--                         getPickerConfig (DateTimeUtils.getMonthInt constraints.maxDate > primaryDateMonthInt)
--                 in
--                 div
--                     [ class "single-calendar-view"
--                     , onMouseLeave ResetShadowDateRange
--                     ]
--                     [ MonthPicker.singleMonthPickerView2 pickerConfig
--
--                     -- , calendarView model
--                     , div [] [ text "implement the new constrainedCalendarView function" ]
--                     ]
--
--             Double ->
--                 let
--                     nextDate =
--                         DateTime.incrementMonth model.primaryDate
--
--                     pickerConfig =
--                         getPickerConfig (DateTimeUtils.getMonthInt constraints.maxDate > DateTimeUtils.getMonthInt nextDate)
--                 in
--                 div
--                     [ class "double-calendar-view"
--                     , onMouseLeave ResetShadowDateRange
--                     ]
--                     [ MonthPicker.doubleMonthPickerView2 pickerConfig
--
--                     -- , calendarView model
--                     -- , calendarView { model | primaryDate = nextDate }
--                     , div [] [ text "implement the new constrainedCalendarView function" ]
--                     ]
--
--     Unconstrained_ model ->
--         div [] []


view : Model -> Html Msg
view model =
    case model.viewType of
        Single ->
            singleCalendarView model

        Double ->
            doubleCalendarView model


doubleCalendarView : Model -> Html Msg
doubleCalendarView model =
    let
        nextDate =
            DateTime.incrementMonth model.primaryDate

        ( isPreviousButtonActive, isNextButtonActive ) =
            case model.constrainedDate of
                Constrained { minDate, maxDate } ->
                    let
                        primaryDateMonthInt =
                            DateTimeUtils.getMonthInt model.primaryDate
                    in
                    ( DateTimeUtils.getMonthInt minDate < primaryDateMonthInt
                    , DateTimeUtils.getMonthInt maxDate > DateTimeUtils.getMonthInt nextDate
                    )

                Unconstrained ->
                    ( isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit
                    , isBetweenFutureLimit model.today nextDate model.futureDatesLimit
                    )

        pickerConfig =
            { date = model.primaryDate
            , nextButtonHandler =
                if isNextButtonActive then
                    Just NextMonth

                else
                    Nothing
            , previousButtonHandler =
                if isPreviousButtonActive then
                    Just PreviousMonth

                else
                    Nothing
            }

        nextModel =
            { model | primaryDate = nextDate }
    in
    div
        [ class "double-calendar-view"
        , onMouseLeave ResetShadowDateRange
        ]
        [ MonthPicker.doubleMonthPickerView2 pickerConfig
        , calendarView model
        , calendarView nextModel
        ]


singleCalendarView : Model -> Html Msg
singleCalendarView model =
    let
        ( isPreviousButtonActive, isNextButtonActive ) =
            case model.constrainedDate of
                Constrained { minDate, maxDate } ->
                    let
                        primaryDateMonthInt =
                            DateTimeUtils.getMonthInt model.primaryDate
                    in
                    ( DateTimeUtils.getMonthInt minDate < primaryDateMonthInt
                    , DateTimeUtils.getMonthInt maxDate > primaryDateMonthInt
                    )

                Unconstrained ->
                    ( isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit
                    , isBetweenFutureLimit model.today model.primaryDate model.futureDatesLimit
                    )

        pickerConfig =
            { date = model.primaryDate
            , nextButtonHandler =
                if isNextButtonActive then
                    Just NextMonth

                else
                    Nothing
            , previousButtonHandler =
                if isPreviousButtonActive then
                    Just PreviousMonth

                else
                    Nothing
            }
    in
    div
        [ class "single-calendar-view"
        , onMouseLeave ResetShadowDateRange
        ]
        [ MonthPicker.singleMonthPickerView2 pickerConfig
        , calendarView model
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


dateHtml : Model -> DateTime -> Html Msg
dateHtml model date =
    let
        ( visualRangeStart, visualRangeEnd ) =
            case model.shadowRangeEnd of
                Just end ->
                    sortMaybeDates model.rangeStart (Just end)

                Nothing ->
                    sortMaybeDates model.rangeStart model.rangeEnd

        isPartOfTheDateRange =
            case ( visualRangeStart, visualRangeEnd ) of
                ( Just start, Just end ) ->
                    (DateTime.compareDates start date == LT)
                        && (DateTime.compareDates end date == GT)

                _ ->
                    False

        constructTheThing isDisabled =
            { isToday = areDatesEqual model.today date
            , isStartOfTheDateRange = Maybe.mapWithDefault (areDatesEqual date) False visualRangeStart
            , isEndOfTheDateRange = Maybe.mapWithDefault (areDatesEqual date) False visualRangeEnd
            , isPartOfTheDateRange = isPartOfTheDateRange
            , visualRangeEnd = visualRangeEnd

            -- , showOnHover = model.showOnHover
            , isDisabled = isDisabled
            }
    in
    case model.constrainedDate of
        Unconstrained ->
            let
                isPastDate =
                    DateTime.compareDates model.today date == GT

                thing =
                    constructTheThing (model.disablePastDates && isPastDate)
            in
            dateHtml_ thing date

        Constrained { minDate, maxDate } ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || areDatesEqual minDate date)
                        && (DateTime.compareDates maxDate date == GT || areDatesEqual maxDate date)

                thing =
                    constructTheThing (not isPartOfTheConstraint)
            in
            dateHtml_ thing date


type alias Thing =
    { isToday : Bool
    , isStartOfTheDateRange : Bool
    , isEndOfTheDateRange : Bool
    , isPartOfTheDateRange : Bool
    , isDisabled : Bool
    , visualRangeEnd : Maybe DateTime

    -- , showOnHover : Bool
    }


dateHtml_ : Thing -> DateTime -> Html Msg
dateHtml_ { isToday, isStartOfTheDateRange, isEndOfTheDateRange, isPartOfTheDateRange, isDisabled, visualRangeEnd } date =
    let
        fullDateString =
            Time.toHumanReadableDate date

        dateClassList =
            [ ( "date", True )
            , ( "today", isToday )
            , ( "selected", isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "date-range", isPartOfTheDateRange )

            -- The "not isEndOfTheDateRange && visualRangeEnd /= Nothing" clause is added in order to fix a css bug.
            , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange && visualRangeEnd /= Nothing )

            -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
            , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )

            -- , ( "invalid-selection", isInvalidSelection )
            , ( "disabled", isDisabled )
            ]
    in
    if isDisabled then
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
            , onMouseOver (DateHoverDetected date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]


dateHtml_old : Model -> DateTime -> Html Msg
dateHtml_old model date =
    let
        rangeEnd =
            case model.shadowRangeEnd of
                Just end ->
                    Just end

                Nothing ->
                    model.rangeEnd

        ( visualRangeStart, visualRangeEnd ) =
            case ( model.rangeStart, rangeEnd ) of
                ( Just start, Just end ) ->
                    case DateTime.compareDates start end of
                        GT ->
                            ( Just end, Just start )

                        _ ->
                            ( Just start, Just end )

                _ ->
                    ( model.rangeStart, rangeEnd )

        fullDateString =
            Time.toHumanReadableDate date

        isToday =
            areDatesEqual model.today date

        isStartOfTheDateRange =
            Maybe.mapWithDefault (areDatesEqual date) False visualRangeStart

        isEndOfTheDateRange =
            Maybe.mapWithDefault (areDatesEqual date) False visualRangeEnd

        isPartOfTheDateRange =
            case ( visualRangeStart, visualRangeEnd ) of
                ( Just start, Just end ) ->
                    (DateTime.compareDates start date == LT) && (DateTime.compareDates end date == GT)

                _ ->
                    False

        isPastDate =
            DateTime.compareDates model.today date == GT

        isDisabledDate =
            model.disablePastDates && isPastDate

        -- isInvalidSelection =
        --     case selectedDate of
        --         Just selectedDate_ ->
        --             let
        --                 dayDiff =
        --                     abs (DateTime.getDayDiff selectedDate_ date)
        --             in
        --             dayDiff < minDateRangeOffset
        --
        --         Nothing ->
        --             False
        dateClassList =
            [ ( "date", True )
            , ( "today", isToday )
            , ( "selected", isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "date-range", isPartOfTheDateRange )

            -- The "not isEndOfTheDateRange && visualRangeEnd /= Nothing" clause is added in order to fix a css bug.
            , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange && visualRangeEnd /= Nothing )

            -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
            , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )

            -- , ( "invalid-selection", isInvalidSelection )
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

            -- , if model.showOnHover then
            --     onMouseOver (DateHoverDetected date)
            --
            --   else
            --     Attributes.none
            , onClick (SelectDate date)
            , onMouseOver (DateHoverDetected date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]


sortMaybeDates : Maybe DateTime -> Maybe DateTime -> ( Maybe DateTime, Maybe DateTime )
sortMaybeDates lhs rhs =
    case ( lhs, rhs ) of
        ( Just start, Just end ) ->
            case DateTime.compareDates start end of
                GT ->
                    ( Just end, Just start )

                _ ->
                    ( Just start, Just end )

        _ ->
            ( lhs, rhs )


areDatesEqual : DateTime -> DateTime -> Bool
areDatesEqual lhs rhs =
    DateTime.compareDates lhs rhs == EQ


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


{-| Extract to another file as a common view fragment
-}
weekdaysHtml : Html msg
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
emptyDateHtml : Html msg
emptyDateHtml =
    span [ class "empty-date" ] []



{- Extract to another file as a common view fragment -}


{-| 6 rows in total on the calendar
--- 7 columns on the calendar
--- 6 \* 7 = 42 is the total count of cells.
-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7
