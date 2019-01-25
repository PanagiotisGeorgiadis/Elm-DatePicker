module Main exposing (Flags, Model, Msg(..), init, main, subscriptions, update, view)

-- import DateTime
-- import Components.DatePicker as DatePicker
-- Maybe not use the DatePicker as a wrapper.
-- import Components.DatePicker.View as DatePicker
-- import Components.DatePicker.Update as DatePicker
--
-- import Models.Calendar exposing (CalendarModel, initialCalendarModel)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Components.DatePicker2.Update as DatePicker2
import Components.DatePicker2.View as DatePicker2
import Components.DateRangePicker.Update as DateRangePicker
import Components.DateRangePicker.View as DateRangePicker
import Components.DateRangePicker.View2 as DateRangePickerView2
import Components.DateRangePicker2.Update as DateRangePicker123
import Components.DateRangePicker2.View as DateRangePicker123
import Components.DoubleDatePicker.Update as DoubleDatePicker
import Components.DoubleDatePicker.View as DoubleDatePicker
import Components.SingleDatePicker.Update as SingleDatePicker
import Components.SingleDatePicker.View as SingleDatePicker
import DateTime.Calendar as Calendar
import DateTime.DateTime as DateTime
import Html exposing (..)
import Models.Calendar as Calendar exposing (DateLimit(..))
import Task
import Time
import Url exposing (Url)
import Utils.Setters exposing (updateDisablePastDates)
import Utils.Time as Time


type alias Flags =
    ()


type alias Model =
    { today : Maybe Time.Posix

    -- , todayCalendar : DateTime.DateTime
    , singleDatePickerModel : Maybe SingleDatePicker.Model
    , doubleDatePickerModel : Maybe DoubleDatePicker.Model

    --
    , singleDatePicker : Maybe DatePicker2.Model
    , singleDateRangePicker : Maybe DateRangePicker.Model

    -- , singleRangePickerModel : Maybe DateRangePicker.Model
    --
    , doubleDatePicker : Maybe DatePicker2.Model
    , doubleDateRangePicker : Maybe DateRangePicker.Model

    -- , doubleRangePickerModel : Maybe DateRangePicker.Model
    --------
    --------
    , newSingleDateRangePicker_C : Maybe DateRangePicker.Model2
    , newDoubleDateRangePicker_C : Maybe DateRangePicker.Model2

    --
    , newSingleDateRangePicker_U : Maybe DateRangePicker.Model2
    , newDoubleDateRangePicker_U : Maybe DateRangePicker.Model2

    ----------
    ----------
    , singleDateRangePicker123 : Maybe DateRangePicker123.Model
    , doubleDateRangePicker123 : Maybe DateRangePicker123.Model

    ----
    , singleConstrainedDateRangePicker123 : Maybe DateRangePicker123.Model
    , doubleConstrainedDateRangePicker123 : Maybe DateRangePicker123.Model
    }


type Msg
    = NoOp
    | Initialise Time.Posix
      -- | DatePickerMsg DatePicker.Msg
    | SingleDatePickerMsg SingleDatePicker.Msg
    | DoubleDatePickerMsg DoubleDatePicker.Msg
      --
    | SingleDatePicker2Msg DatePicker2.Msg
    | SingleDateRangeMsg DateRangePicker.Msg
      --
    | DoubleDatePicker2Msg DatePicker2.Msg
    | DoubleDateRangeMsg DateRangePicker.Msg
      -------
      -------
    | NewSingleDateRangeMsg_C DateRangePicker.Msg
    | NewDoubleDateRangeMsg_C DateRangePicker.Msg
    | NewSingleDateRangeMsg_U DateRangePicker.Msg
    | NewDoubleDateRangeMsg_U DateRangePicker.Msg
      --------------
      --------------
    | SingleDateRangeMsg123 DateRangePicker123.Msg
    | DoubleDateRangeMsg123 DateRangePicker123.Msg
    | SingleDateRangeMsg123_C DateRangePicker123.Msg
    | DoubleDateRangeMsg123_C DateRangePicker123.Msg



-- | SingleDatePickerMsg SingleDatePicker.Msg
-- | DoubleDatePickerMsg DatePicker.Msg
{-
   Configs to add:
   1) disablePastDates :: Bool    -- DONE.
   2) showOnHover selection       -- DONE.
   3) useKeyboardListeners ( Only on single date picker ? ) -- Think about that.
   4) minDateRangeOffset :: Int -- Think about how to implement that.
   5) futureDatesLimit :: DateLimit -- DONE
   6) pastDatesLimit :: DateLimit   -- DONE
   7) showHumanReadableDateString ?
   8) humanReadableDateFormat ?
        Example:
            type DateFormat = US | EU
   9) minAvailableDate.
   10) maxAvailableDate.
   11) availableDateRange -- We could combine the two properties above into a date range list.


   Check the contenteditable if it can be implemented as a single line
   only for the time picker.

   Also check the start and end dates to always be sorted even if the user
   selects the start date after the end date.

-}


view : Model -> Document Msg
view model =
    -- let
    --     dateTime =
    --         DateTime.fromPosix model.today
    --
    --     month =
    --         DateTime.getMonth dateTime
    -- in
    { title = "My DatePicker"
    , body =
        [ div []
            -- [ text "HALLOWWW 12345"
            -- , br [] []
            -- , text <| Debug.toString model.today
            -- , br [] []
            -- , text <| Time.toHumanReadableTime model.timezone model.today
            -- , br [] []
            -- , text <| Time.toHumanReadableTime model.timezone (Time.millisToPosix 0)
            -- , br [] []
            -- , br [] []
            -- , DatePicker.doubleMonthRangeView model.todayCalendar
            -- ]
            [ text "Single Calendar View"

            -- , Html.map DatePickerMsg (DatePicker.singleDatePickerView (DateTime.date dateTime))
            -- , Html.map SingleDatePickerMsg (DatePicker.singleDatePickerView model.singleDatePickerModel)
            -- , Html.map SingleDatePickerMsg (DatePicker.singleDatePickerView model.singleDatePickerModel)
            , case model.singleDatePickerModel of
                Just m ->
                    Html.map SingleDatePickerMsg (SingleDatePicker.view m)

                Nothing ->
                    text "Some error has happened on the main model."

            -- , Html.map SingleDatePickerMsg (SingleDatePicker.view model.singleDatePickerModel)
            , br [] []
            , br [] []
            , text "Double Calendar View"

            -- , Html.map DatePickerMsg (DatePicker.doubleDatePickerView (DateTime.date dateTime))
            -- , Html.map DoubleDatePickerMsg (DatePicker.doubleDatePickerView model.doubleDatePickerModel)
            , case model.doubleDatePickerModel of
                Just m ->
                    Html.map DoubleDatePickerMsg (DoubleDatePicker.view m)

                Nothing ->
                    text "Some error has happened on the main model."

            -- , Html.map DoubleDatePickerMsg (DoubleDatePicker.view model.doubleDatePickerModel)
            , br [] []
            , br [] []
            , text "New Implementation as components."
            , br [] []
            , br [] []
            , text "Single Date Picker"
            , case model.singleDatePicker of
                Just m ->
                    Html.map SingleDatePicker2Msg (DatePicker2.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , text "Double Date Picker"
            , case model.doubleDatePicker of
                Just m ->
                    Html.map DoubleDatePicker2Msg (DatePicker2.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "Single Date Range Picker"
            , case model.singleDateRangePicker of
                Just m ->
                    Html.map SingleDateRangeMsg (DateRangePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "Double Date Range Picker"
            , case model.doubleDateRangePicker of
                Just m ->
                    Html.map DoubleDateRangeMsg (DateRangePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            , text "NEW IMPLEMENTATION Version 24.56.95 >_<"
            , br [] []
            , text "CONSTRAINED Single Date Range Picker"
            , case model.newSingleDateRangePicker_C of
                Just m ->
                    Html.map NewSingleDateRangeMsg_C (DateRangePickerView2.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "CONSTRAINED Double Date Range Picker"
            , case model.newDoubleDateRangePicker_C of
                Just m ->
                    Html.map NewDoubleDateRangeMsg_C (DateRangePickerView2.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "UN-CONSTRAINED Single Date Range Picker"
            , case model.newSingleDateRangePicker_U of
                Just m ->
                    Html.map NewSingleDateRangeMsg_U (DateRangePickerView2.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "UN-CONSTRAINED Double Date Range Picker"
            , case model.newDoubleDateRangePicker_U of
                Just m ->
                    Html.map NewDoubleDateRangeMsg_U (DateRangePickerView2.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            , text "======================================================================================"
            , br [] []
            , text "======================================================================================"
            , br [] []
            , text "Single Date Range Picker"
            , case model.singleDateRangePicker123 of
                Just datePickerModel ->
                    Html.map SingleDateRangeMsg123 (DateRangePicker123.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "Double Date Range Picker"
            , case model.doubleDateRangePicker123 of
                Just datePickerModel ->
                    Html.map DoubleDateRangeMsg123 (DateRangePicker123.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "Single Constrained Date Range Picker"
            , case model.singleConstrainedDateRangePicker123 of
                Just datePickerModel ->
                    Html.map SingleDateRangeMsg123_C (DateRangePicker123.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , text "Double Constrained Date Range Picker"
            , case model.doubleConstrainedDateRangePicker123 of
                Just datePickerModel ->
                    Html.map DoubleDateRangeMsg123_C (DateRangePicker123.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            ]
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        Initialise todayPosix ->
            let
                todayDateTime =
                    DateTime.fromPosix todayPosix

                singleDatePickerConfig =
                    { disablePastDates = False
                    }

                doubleDatePickerConfig =
                    { showOnHover = True
                    , disablePastDates = True
                    , minDateRangeOffset = 3
                    , pastDatesLimit = MonthLimit 24
                    , futureDatesLimit = MonthLimit 24
                    }

                singleDatePicker2Config =
                    { today = todayDateTime
                    , viewType = DatePicker2.Single
                    , primaryDate = todayDateTime
                    , pastDatesLimit = MonthLimit 12
                    , futureDatesLimit = MonthLimit 12
                    , disablePastDates = True
                    }

                doubleDatePicker2Config =
                    { today = todayDateTime
                    , viewType = DatePicker2.Double
                    , primaryDate = todayDateTime
                    , pastDatesLimit = MonthLimit 12
                    , futureDatesLimit = MonthLimit 12
                    , disablePastDates = True
                    }

                ( thirdOfFeb, eighthOfFeb ) =
                    ( 1549152000000
                    , 1549584000000
                    )

                ( sixteenOfMar, sixteenOfApr ) =
                    ( 1552694400000
                    , 1555372800000
                    )

                singleDateRangeConfig =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Single
                    , primaryDate = todayDateTime
                    , showOnHover = False
                    , disablePastDates = True

                    -- , minDateRangeOffset : Int
                    , pastDatesLimit = MonthLimit 2
                    , futureDatesLimit = MonthLimit 2

                    -- , constrainedDate = DateRangePicker.Unconstrained
                    , constrainedDate =
                        DateRangePicker.Constrained
                            { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                            , maxDate = DateTime.fromPosix (Time.millisToPosix eighthOfFeb)
                            }
                    }

                doubleDateRangeConfig =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Double
                    , primaryDate = todayDateTime
                    , showOnHover = True
                    , disablePastDates = True

                    -- , minDateRangeOffset : Int
                    , pastDatesLimit = MonthLimit 6

                    -- , futureDatesLimit = MonthLimit 2
                    , futureDatesLimit = MonthLimit 6
                    , constrainedDate = DateRangePicker.Unconstrained

                    -- , constrainedDate =
                    --     DateRangePicker.Constrained
                    --         { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                    --         , maxDate = DateTime.fromPosix (Time.millisToPosix sixteenOfMar)
                    --         }
                    }

                newSingleDateRangePickerConfig_Constrained =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Single
                    }

                newDoubleDateRangePickerConfig_Constrained =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Double
                    }

                constrains =
                    { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                    , maxDate = DateTime.fromPosix (Time.millisToPosix sixteenOfMar)
                    }

                newSingleDateRangePickerConfig_Unconstrained =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Single
                    , primaryDate = todayDateTime
                    , disablePastDates = True
                    , pastDatesLimit = MonthLimit 6
                    , futureDatesLimit = MonthLimit 6
                    }

                newDoubleDateRangePickerConfig_Unconstrained =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Double
                    , primaryDate = todayDateTime
                    , disablePastDates = True
                    , pastDatesLimit = MonthLimit 6
                    , futureDatesLimit = MonthLimit 6
                    }

                singleDateRangePickerConfig123 =
                    { today = todayDateTime
                    , viewType = DateRangePicker123.Single
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker123.NoLimit { disablePastDates = True }
                    }

                doubleDateRangePickerConfig123 =
                    { today = todayDateTime
                    , viewType = DateRangePicker123.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker123.NoLimit { disablePastDates = True }
                    }

                singleDateRangePickerConfig123_C =
                    { today = todayDateTime
                    , viewType = DateRangePicker123.Single
                    , primaryDate = todayDateTime
                    , dateLimit =
                        DateRangePicker123.DateLimit
                            { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                            , maxDate = DateTime.fromPosix (Time.millisToPosix sixteenOfApr)
                            }
                    }

                doubleDateRangePickerConfig123_C =
                    { today = todayDateTime
                    , viewType = DateRangePicker123.Double
                    , primaryDate = todayDateTime
                    , dateLimit =
                        DateRangePicker123.DateLimit
                            { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                            , maxDate = DateTime.fromPosix (Time.millisToPosix sixteenOfApr)
                            }
                    }
            in
            ( { model
                | today = Just todayPosix
                , singleDatePickerModel = Just (SingleDatePicker.initialise singleDatePickerConfig todayDateTime)
                , doubleDatePickerModel = Just (DoubleDatePicker.initialise doubleDatePickerConfig todayDateTime)

                --
                , singleDatePicker = Just (DatePicker2.initialise singleDatePicker2Config)
                , singleDateRangePicker = Just (DateRangePicker.initialise singleDateRangeConfig)

                --
                , doubleDatePicker = Just (DatePicker2.initialise doubleDatePicker2Config)
                , doubleDateRangePicker = Just (DateRangePicker.initialise doubleDateRangeConfig)

                -------
                -------
                , newSingleDateRangePicker_C = Just (DateRangePicker.initialiseConstrainedCalendar2 newSingleDateRangePickerConfig_Constrained constrains)
                , newDoubleDateRangePicker_C = Just (DateRangePicker.initialiseConstrainedCalendar2 newDoubleDateRangePickerConfig_Constrained constrains)

                --
                , newSingleDateRangePicker_U = Just (DateRangePicker.initialiseUnconstrainedCalendar2 newSingleDateRangePickerConfig_Unconstrained)
                , newDoubleDateRangePicker_U = Just (DateRangePicker.initialiseUnconstrainedCalendar2 newDoubleDateRangePickerConfig_Unconstrained)

                ------------
                ------------
                , singleDateRangePicker123 = Just (DateRangePicker123.initialise singleDateRangePickerConfig123)
                , doubleDateRangePicker123 = Just (DateRangePicker123.initialise doubleDateRangePickerConfig123)

                ----
                , singleConstrainedDateRangePicker123 = Just (DateRangePicker123.initialise singleDateRangePickerConfig123_C)
                , doubleConstrainedDateRangePicker123 = Just (DateRangePicker123.initialise doubleDateRangePickerConfig123_C)
              }
            , Cmd.none
            )

        -- SingleDatePickerMsg subMsg ->
        --     let
        --         ( updatedSubModel, subCmd, extMsg ) =
        --             DatePicker.update model.singleDatePickerModel subMsg
        --     in
        --     ( { model
        --         | singleDatePickerModel = updatedSubModel
        --       }
        --     , Cmd.map SingleDatePickerMsg subCmd
        --     )
        -- DoubleDatePickerMsg subMsg ->
        --     let
        --         ( updatedSubModel, subCmd, extMsg ) =
        --             DatePicker.update model.doubleDatePickerModel subMsg
        --     in
        --     ( { model
        --         | doubleDatePickerModel = updatedSubModel
        --       }
        --     , Cmd.map DoubleDatePickerMsg subCmd
        --     )
        SingleDatePickerMsg subMsg ->
            case model.singleDatePickerModel of
                Just singleDatePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            SingleDatePicker.update singleDatePickerModel subMsg
                    in
                    ( { model
                        | singleDatePickerModel = Just subModel
                      }
                    , Cmd.map SingleDatePickerMsg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDatePickerMsg subMsg ->
            case model.doubleDatePickerModel of
                Just doubleDatePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            DoubleDatePicker.update doubleDatePickerModel subMsg
                    in
                    ( { model
                        | doubleDatePickerModel = Just subModel
                      }
                    , Cmd.map DoubleDatePickerMsg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        SingleDatePicker2Msg subMsg ->
            case model.singleDatePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DatePicker2.update subMsg datePickerModel
                    in
                    ( { model | singleDatePicker = Just subModel }
                    , Cmd.map SingleDatePicker2Msg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDatePicker2Msg subMsg ->
            case model.doubleDatePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DatePicker2.update subMsg datePickerModel
                    in
                    ( { model | doubleDatePicker = Just subModel }
                    , Cmd.map DoubleDatePicker2Msg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        SingleDateRangeMsg subMsg ->
            case model.singleDateRangePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update subMsg datePickerModel
                    in
                    ( { model | singleDateRangePicker = Just subModel }
                    , Cmd.map SingleDateRangeMsg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDateRangeMsg subMsg ->
            case model.doubleDateRangePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update subMsg datePickerModel
                    in
                    ( { model | doubleDateRangePicker = Just subModel }
                    , Cmd.map DoubleDateRangeMsg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        NewSingleDateRangeMsg_C subMsg ->
            case model.newSingleDateRangePicker_C of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update2 subMsg datePickerModel
                    in
                    ( { model | newSingleDateRangePicker_C = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        NewDoubleDateRangeMsg_C subMsg ->
            case model.newDoubleDateRangePicker_C of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update2 subMsg datePickerModel
                    in
                    ( { model | newDoubleDateRangePicker_C = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        NewSingleDateRangeMsg_U subMsg ->
            case model.newSingleDateRangePicker_U of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update2 subMsg datePickerModel
                    in
                    ( { model | newSingleDateRangePicker_U = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        NewDoubleDateRangeMsg_U subMsg ->
            case model.newDoubleDateRangePicker_U of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update2 subMsg datePickerModel
                    in
                    ( { model | newDoubleDateRangePicker_U = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        ------
        SingleDateRangeMsg123 subMsg ->
            case model.singleDateRangePicker123 of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker123.update subMsg datePickerModel
                    in
                    ( { model | singleDateRangePicker123 = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDateRangeMsg123 subMsg ->
            case model.doubleDateRangePicker123 of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker123.update subMsg datePickerModel
                    in
                    ( { model | doubleDateRangePicker123 = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        SingleDateRangeMsg123_C subMsg ->
            case model.singleConstrainedDateRangePicker123 of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker123.update subMsg datePickerModel
                    in
                    ( { model | singleConstrainedDateRangePicker123 = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDateRangeMsg123_C subMsg ->
            case model.doubleConstrainedDateRangePicker123 of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker123.update subMsg datePickerModel
                    in
                    ( { model | doubleConstrainedDateRangePicker123 = Just subModel }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { today = Nothing
      , singleDatePickerModel = Nothing
      , doubleDatePickerModel = Nothing

      --
      , singleDatePicker = Nothing
      , singleDateRangePicker = Nothing

      --
      , doubleDatePicker = Nothing
      , doubleDateRangePicker = Nothing

      --------
      --------
      , newSingleDateRangePicker_C = Nothing
      , newDoubleDateRangePicker_C = Nothing

      --
      , newSingleDateRangePicker_U = Nothing
      , newDoubleDateRangePicker_U = Nothing

      ------------
      ------------
      , singleDateRangePicker123 = Nothing
      , doubleDateRangePicker123 = Nothing

      ----
      , singleConstrainedDateRangePicker123 = Nothing
      , doubleConstrainedDateRangePicker123 = Nothing
      }
    , Task.perform Initialise Time.now
    )


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
