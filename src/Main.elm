module Main exposing (Flags, Model, Msg(..), init, main, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Components.DatePicker.Update as DatePicker
import Components.DatePicker.View as DatePicker
import Components.DateRangePicker2.Update as DateRangePicker123
import Components.DateRangePicker2.View as DateRangePicker123
import Components.TimePicker.Update as TimePicker
import DateTime as DateTime
import Html exposing (..)
import Task
import Time
import Url exposing (Url)
import Utils.Setters exposing (updateDisablePastDates)
import Utils.Time as Time


type alias Flags =
    ()


type alias Model =
    { today : Maybe Time.Posix
    , singleDatePicker : Maybe DatePicker.Model
    , doubleDatePicker : Maybe DatePicker.Model
    , singleDateRangePicker123 : Maybe DateRangePicker123.Model
    , doubleDateRangePicker123 : Maybe DateRangePicker123.Model
    , singleConstrainedDateRangePicker123 : Maybe DateRangePicker123.Model
    , doubleConstrainedDateRangePicker123 : Maybe DateRangePicker123.Model
    }


type Msg
    = NoOp
    | Initialise Time.Posix
    | SingleDatePicker2Msg DatePicker.Msg
    | DoubleDatePicker2Msg DatePicker.Msg
    | SingleDateRangeMsg123 DateRangePicker123.Msg
    | DoubleDateRangeMsg123 DateRangePicker123.Msg
    | SingleDateRangeMsg123_C DateRangePicker123.Msg
    | DoubleDateRangeMsg123_C DateRangePicker123.Msg



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
    { title = "My DatePicker"
    , body =
        [ div []
            [ br [] []
            , br [] []
            , br [] []
            , text "New Implementation as components."
            , br [] []
            , br [] []
            , text "Single Date Picker"
            , case model.singleDatePicker of
                Just m ->
                    Html.map SingleDatePicker2Msg (DatePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , text "Double Date Picker"
            , case model.doubleDatePicker of
                Just m ->
                    Html.map DoubleDatePicker2Msg (DatePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            , br [] []
            , text "NEW IMPLEMENTATION Version 24.56.95 >_<"
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

                ( thirdOfFeb, eighthOfFeb ) =
                    ( 1549152000000
                    , 1549584000000
                    )

                ( sixteenOfMar, sixteenOfApr ) =
                    ( 1552694400000
                    , 1555372800000
                    )

                singleDatePicker2Config =
                    { today = todayDateTime
                    , viewType = DatePicker.Single
                    , primaryDate = todayDateTime
                    , dateLimit =
                        DatePicker.DateLimit
                            { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                            , maxDate = DateTime.fromPosix (Time.millisToPosix sixteenOfApr)
                            }
                    }

                doubleDatePicker2Config =
                    { today = todayDateTime
                    , viewType = DatePicker.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DatePicker.NoLimit { disablePastDates = True }
                    }

                constrains =
                    { minDate = DateTime.fromPosix (Time.millisToPosix thirdOfFeb)
                    , maxDate = DateTime.fromPosix (Time.millisToPosix sixteenOfMar)
                    }

                singleDateRangePickerConfig123 =
                    { today = todayDateTime
                    , viewType = DateRangePicker123.Single
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker123.NoLimit { disablePastDates = True }
                    , mirrorTimes = True
                    , pickerType = TimePicker.HH_MM_SS { hoursStep = 1, minutesStep = 1, secondsStep = 1 }
                    }

                doubleDateRangePickerConfig123 =
                    { today = todayDateTime
                    , viewType = DateRangePicker123.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker123.NoLimit { disablePastDates = True }
                    , mirrorTimes = True
                    , pickerType = TimePicker.HH_MM { hoursStep = 1, minutesStep = 1 }
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
                    , mirrorTimes = True
                    , pickerType = TimePicker.HH_MM_SS { hoursStep = 1, minutesStep = 1, secondsStep = 1 }
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
                    , mirrorTimes = True
                    , pickerType = TimePicker.HH_MM { hoursStep = 1, minutesStep = 10 }
                    }
            in
            ( { model
                | today = Just todayPosix
                , singleDatePicker = Just (DatePicker.initialise singleDatePicker2Config)
                , doubleDatePicker = Just (DatePicker.initialise doubleDatePicker2Config)
                , singleDateRangePicker123 = Just (DateRangePicker123.initialise singleDateRangePickerConfig123)
                , doubleDateRangePicker123 = Just (DateRangePicker123.initialise doubleDateRangePickerConfig123)
                , singleConstrainedDateRangePicker123 = Just (DateRangePicker123.initialise singleDateRangePickerConfig123_C)
                , doubleConstrainedDateRangePicker123 = Just (DateRangePicker123.initialise doubleDateRangePickerConfig123_C)
              }
            , Cmd.none
            )

        SingleDatePicker2Msg subMsg ->
            case model.singleDatePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            DatePicker.update subMsg datePickerModel
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
                        ( subModel, subCmd, extMsg ) =
                            DatePicker.update subMsg datePickerModel
                    in
                    ( { model | doubleDatePicker = Just subModel }
                    , Cmd.map DoubleDatePicker2Msg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

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
                    , Cmd.map DoubleDateRangeMsg123_C subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { today = Nothing
      , singleDatePicker = Nothing
      , doubleDatePicker = Nothing
      , singleDateRangePicker123 = Nothing
      , doubleDateRangePicker123 = Nothing
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
