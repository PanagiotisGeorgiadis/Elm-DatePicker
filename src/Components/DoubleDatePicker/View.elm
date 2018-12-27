module Components.DoubleDatePicker.View exposing (doubleDatePickerView, view)

-- import DateTime.Calendar as Calendar

import Components.Calendar as Calendar
import Components.DoubleDatePicker.Update exposing (..)
import Components.MonthPicker as MonthPicker
import DateTime.DateTime as DateTime
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseLeave)
import Models.Calendar exposing (CalendarViewModel)


view : Model -> Html Msg
view =
    doubleDatePickerView


doubleDatePickerView : Model -> Html Msg
doubleDatePickerView model =
    let
        nextDate =
            -- Calendar.getNextMonth model.primaryDate
            DateTime.getNextMonth model.primaryDate

        nextModel =
            { model | primaryDate = nextDate }

        -- ( rangeStart, rangeEnd ) =
        --     ( List.head model.dateRange
        --     , List.head (List.reverse model.dateRange)
        --     )
        pickerConfig =
            { date = model.primaryDate
            , previousButtonHandler = Just PreviousMonth
            , nextButtonHandler = Just NextMonth

            -- , dateSelectionHandler = Nothing
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
            , onHoverListener = Just DateHoverDetected
            , rangeStart = model.rangeStart

            -- , rangeEnd = model.rangeEnd
            , rangeEnd = rangeEnd
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
