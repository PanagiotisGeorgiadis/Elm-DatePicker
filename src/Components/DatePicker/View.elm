module Components.DatePicker.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Components.DatePicker.Update exposing (..)

-- import Time exposing (Month)
import Components.MonthPicker as MonthPicker
import Components.Calendar as Calendar

import DateTime.Calendar as Calendar

-- import DateTime.DateTime as DateTime exposing (DateTime)
import Models.Calendar exposing (CalendarModel, CalendarViewModel)

import Components.SingleDatePicker.View as SingleDatePicker
import Components.SingleDatePicker.Update as SingleDatePicker


import Components.DoubleDatePicker.View as DoubleDatePicker
import Components.DoubleDatePicker.Update as DoubleDatePicker


view : Html Msg
view = div [] []

-- singleDatePickerView : CalendarModel -> Html Msg
-- singleDatePickerView model =
--     let
--         pickerConfig =
--             { date = model.primaryDate
--             , previousButtonHandler = Just PreviousMonth
--             , nextButtonHandler = Just NextMonth
--             -- , dateSelectionHandler = Just SelectDate
--             }
--     in
--     div [ class "single-calendar-view" ]
--         [ MonthPicker.singleMonthPickerView2 pickerConfig
--         , Calendar.view2 model (CalendarViewModel (Just SelectDate) model.singleDate)
--         ]

-- singleDatePickerView : SingleDatePicker.Model -> Html Msg
-- singleDatePickerView model =
--     Html.map SingleDatePickerMsg (SingleDatePicker.view model)


-- doubleDatePickerView : CalendarModel -> Html Msg
-- doubleDatePickerView model =
--     let
--         nextDate =
--             Calendar.getNextMonth model.primaryDate
--
--         nextModel =
--             { model | primaryDate = nextDate }
--
--         ( rangeStart, rangeEnd ) =
--             ( List.head model.dateRange
--             , List.head (List.reverse model.dateRange)
--             )
--
--         pickerConfig =
--             { date = model.primaryDate
--             , previousButtonHandler = Just PreviousMonth
--             , nextButtonHandler = Just NextMonth
--             -- , dateSelectionHandler = Nothing
--             }
--     in
--     div [ class "double-calendar-view" ]
--         [ MonthPicker.doubleMonthPickerView2 pickerConfig
--         , Calendar.view2 model (CalendarViewModel (Nothing) rangeStart)
--         , Calendar.view2 nextModel (CalendarViewModel (Nothing) rangeEnd)
--         ]

-- doubleDatePickerView : DoubleDatePicker.Model -> Html Msg
-- doubleDatePickerView model =
--     div [] []
