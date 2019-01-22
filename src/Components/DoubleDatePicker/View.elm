module Components.DoubleDatePicker.View exposing (doubleDatePickerView, view)

-- import Components.Calendar2 as Calendar2

import Components.Calendar as Calendar
import Components.DoubleDatePicker.Update exposing (..)
import Components.MonthPicker as MonthPicker
import DateTime.DateTime as DateTime
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseLeave)
import Models.Calendar exposing (CalendarViewModel, isBetweenFutureLimit, isBetweenPastLimit)


view : Model -> Html Msg
view =
    doubleDatePickerView


doubleDatePickerView : Model -> Html Msg
doubleDatePickerView model =
    let
        nextDate =
            DateTime.getNextMonth model.primaryDate

        nextModel =
            { model | primaryDate = nextDate }

        pickerConfig =
            { date = model.primaryDate
            , previousButtonHandler =
                if isBetweenPastLimit model.today (DateTime.getPreviousMonth model.primaryDate) model.pastDatesLimit then
                    Just PreviousMonth

                else
                    Nothing
            , nextButtonHandler =
                if isBetweenFutureLimit model.today nextDate model.futureDatesLimit then
                    Just NextMonth

                else
                    Nothing
            }

        rangeEnd =
            case ( model.rangeEnd, model.shadowRangeEnd ) of
                ( Just end, _ ) ->
                    Just end

                ( _, Just end ) ->
                    Just end

                _ ->
                    model.rangeEnd

        calendarViewModel =
            { dateSelectionHandler = Just SelectDate
            , selectedDate = Nothing
            , onHoverListener =
                if model.showOnHover then
                    Just DateHoverDetected

                else
                    Nothing
            , rangeStart = model.rangeStart
            , rangeEnd = rangeEnd

            -- , minDateRangeOffset = model.minDateRangeOffset
            }
    in
    div
        [ class "double-calendar-view"
        , onMouseLeave ResetShadowDateRange
        ]
        [ MonthPicker.doubleMonthPickerView2 pickerConfig

        -- , Calendar.view2 model (CalendarViewModel (Just SelectDate) rangeStart (Just DateHoverDetected))
        , Calendar.view2 model calendarViewModel

        -- , Calendar.view2 nextModel (CalendarViewModel (Just SelectDate) rangeEnd (Just DateHoverDetected))
        , Calendar.view2 nextModel calendarViewModel
        ]
