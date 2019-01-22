module Components.SingleDatePicker.View exposing (singleDatePickerView, view)

import Components.Calendar as Calendar
import Components.MonthPicker as MonthPicker
import Components.SingleDatePicker.Update exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Models.Calendar exposing (CalendarViewModel)


view : Model -> Html Msg
view =
    singleDatePickerView


singleDatePickerView : Model -> Html Msg
singleDatePickerView model =
    let
        pickerConfig =
            { date = model.primaryDate
            , previousButtonHandler = Just PreviousMonth
            , nextButtonHandler = Just NextMonth

            -- , dateSelectionHandler = Just SelectDate
            }

        calendarViewModel =
            { dateSelectionHandler = Just SelectDate
            , selectedDate = model.selectedDate
            , onHoverListener = Nothing
            , rangeStart = Nothing
            , rangeEnd = Nothing
            }
    in
    div [ class "single-calendar-view" ]
        [ MonthPicker.singleMonthPickerView2 pickerConfig

        -- , Calendar.view2 model (CalendarViewModel (Just SelectDate) model.selectedDate Nothing)
        , Calendar.view2 model calendarViewModel
        ]
