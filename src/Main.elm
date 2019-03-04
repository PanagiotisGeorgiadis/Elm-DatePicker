module Main exposing (Flags, Model, Msg(..), init, main, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Clock
import Components.DatePicker.Update as DatePicker
import Components.DatePicker.View as DatePicker
import Components.DateRangePicker.Update as DateRangePicker
import Components.DateRangePicker.View as DateRangePicker
import Components.TimePicker.Update as TimePicker
import DateTime as DateTime
import Html exposing (Html, br, div, hr, text)
import Task
import Time
import Url exposing (Url)
import Utils.Time as Time


type alias Flags =
    ()


type alias Model =
    { today : Maybe Time.Posix
    , singleDatePicker : Maybe DatePicker.Model
    , doubleDatePicker : Maybe DatePicker.Model

    -- TODO: Implement those to just for completion
    , singleDatePicker_C : Maybe DatePicker.Model
    , doubleDatePicker_C : Maybe DatePicker.Model
    , singleDateRangePicker : Maybe DateRangePicker.Model
    , doubleDateRangePicker : Maybe DateRangePicker.Model
    , singleDateRangePicker_C : Maybe DateRangePicker.Model
    , doubleDateRangePicker_C : Maybe DateRangePicker.Model
    }


type Msg
    = NoOp
    | Initialise Time.Posix
    | SingleDatePickerMsg DatePicker.Msg
    | DoubleDatePickerMsg DatePicker.Msg
      -- TODO: Implement those two just for completion
    | SingleDatePickerMsg_C DatePicker.Msg
    | DoubleDatePickerMsg_C DatePicker.Msg
    | SingleDateRangeMsg DateRangePicker.Msg
    | DoubleDateRangeMsg DateRangePicker.Msg
    | SingleDateRangeMsg_C DateRangePicker.Msg
    | DoubleDateRangeMsg_C DateRangePicker.Msg



{-
   Configs to add:
   1) disablePastDates :: Bool    -- DONE.
   2) showOnHover selection       -- DONE.
   3) useKeyboardListeners ( Only on single date picker ? ) -- Think about that.
   4) minDateRangeOffset :: Int -- Think about how to implement that. ( DONE )
   5) futureDatesLimit :: DateLimit -- DONE
   6) pastDatesLimit :: DateLimit   -- DONE
   7) showHumanReadableDateString ?
   8) humanReadableDateFormat ?
        Example:
            type DateFormat = US | EU
   9) minAvailableDate.     ( DONE )
   10) maxAvailableDate.    ( DONE )
   11) availableDateRange -- We could combine the two properties above into a date range list.


   Check the contenteditable if it can be implemented as a single line
   only for the time picker.  ( NOPE )

   Also check the start and end dates to always be sorted even if the user
   selects the start date after the end date. ( DONE )

-}


view : Model -> Document Msg
view model =
    { title = "My DatePicker"
    , body =
        [ div []
            [ br [] []
            , text "Single Date Picker"
            , br [] []
            , case model.singleDatePicker of
                Just m ->
                    Html.map SingleDatePickerMsg (DatePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , text "Double Date Picker"
            , br [] []
            , case model.doubleDatePicker of
                Just m ->
                    Html.map DoubleDatePickerMsg (DatePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , text "Single Date Picker Constrained"
            , br [] []
            , case model.singleDatePicker_C of
                Just m ->
                    Html.map SingleDatePickerMsg_C (DatePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , text "Double Date Picker Constrained"
            , br [] []
            , case model.doubleDatePicker_C of
                Just m ->
                    Html.map DoubleDatePickerMsg_C (DatePicker.view m)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , hr [] []
            , br [] []
            , text "Single Date Range Picker"
            , br [] []
            , case model.singleDateRangePicker of
                Just datePickerModel ->
                    Html.map SingleDateRangeMsg (DateRangePicker.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , text "Double Date Range Picker"
            , br [] []
            , case model.doubleDateRangePicker of
                Just datePickerModel ->
                    Html.map DoubleDateRangeMsg (DateRangePicker.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , text "Single Date Range Picker Constrained"
            , br [] []
            , case model.singleDateRangePicker_C of
                Just datePickerModel ->
                    Html.map SingleDateRangeMsg_C (DateRangePicker.view datePickerModel)

                Nothing ->
                    text "Error!"
            , br [] []
            , br [] []
            , br [] []
            , text "Double Date Range Picker Constrained"
            , br [] []
            , case model.doubleDateRangePicker_C of
                Just datePickerModel ->
                    Html.map DoubleDateRangeMsg_C (DateRangePicker.view datePickerModel)

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

                ( thirdOfFeb, sixteenOfApr ) =
                    ( Time.millisToPosix 1549152000000
                    , Time.millisToPosix 1555372800000
                    )

                constrains =
                    { minDate = DateTime.fromPosix thirdOfFeb
                    , maxDate = DateTime.fromPosix sixteenOfApr
                    }

                pickerType =
                    TimePicker.HH_MM_SS { hoursStep = 1, minutesStep = 5, secondsStep = 10 }

                defaultTime =
                    Maybe.withDefault
                        Clock.midnight
                        (Clock.fromRawParts { hours = 11, minutes = 11, seconds = 11, milliseconds = 0 })

                singleDatePickerConfig =
                    { today = todayDateTime
                    , viewType = DatePicker.Single
                    , primaryDate = todayDateTime
                    , dateLimit = DatePicker.NoLimit { disablePastDates = True }
                    , timePickerConfig = DatePicker.TimePickerConfig { pickerType = pickerType, defaultTime = defaultTime }
                    }

                doubleDatePickerConfig =
                    { today = todayDateTime
                    , viewType = DatePicker.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DatePicker.NoLimit { disablePastDates = True }
                    , timePickerConfig = DatePicker.TimePickerConfig { pickerType = pickerType, defaultTime = defaultTime }
                    }

                singleDatePickerConfig_C =
                    { today = todayDateTime
                    , viewType = DatePicker.Single
                    , primaryDate = todayDateTime
                    , dateLimit = DatePicker.DateLimit constrains
                    , timePickerConfig = DatePicker.TimePickerConfig { pickerType = pickerType, defaultTime = defaultTime }
                    }

                doubleDatePickerConfig_C =
                    { today = todayDateTime
                    , viewType = DatePicker.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DatePicker.DateLimit constrains
                    , timePickerConfig = DatePicker.TimePickerConfig { pickerType = pickerType, defaultTime = defaultTime }
                    }

                dateRangePickerConfig =
                    TimePicker.HH_MM { hoursStep = 1, minutesStep = 5 }

                singleDateRangePickerConfig =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Single
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker.NoLimit { disablePastDates = True }

                    --
                    , timePickerConfig =
                        Just (DateRangePicker.TimePickerConfig { pickerType = dateRangePickerConfig, defaultTime = defaultTime, mirrorTimes = True })
                    }

                doubleDateRangePickerConfig =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker.NoLimit { disablePastDates = True }

                    --
                    , timePickerConfig =
                        Just (DateRangePicker.TimePickerConfig { pickerType = dateRangePickerConfig, defaultTime = defaultTime, mirrorTimes = True })
                    }

                singleDateRangePickerConfig_C =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Single
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker.DateLimit constrains

                    --
                    , timePickerConfig =
                        Just (DateRangePicker.TimePickerConfig { pickerType = dateRangePickerConfig, defaultTime = defaultTime, mirrorTimes = True })
                    }

                doubleDateRangePickerConfig_C =
                    { today = todayDateTime
                    , viewType = DateRangePicker.Double
                    , primaryDate = todayDateTime
                    , dateLimit = DateRangePicker.DateLimit constrains

                    --
                    , timePickerConfig =
                        Just (DateRangePicker.TimePickerConfig { pickerType = dateRangePickerConfig, defaultTime = defaultTime, mirrorTimes = True })
                    }
            in
            ( { model
                | today = Just todayPosix

                --
                , singleDatePicker = Just (DatePicker.initialise singleDatePickerConfig)
                , doubleDatePicker = Just (DatePicker.initialise doubleDatePickerConfig)
                , singleDatePicker_C = Just (DatePicker.initialise singleDatePickerConfig_C)
                , doubleDatePicker_C = Just (DatePicker.initialise doubleDatePickerConfig_C)

                --
                , singleDateRangePicker = Just (DateRangePicker.initialise singleDateRangePickerConfig)
                , doubleDateRangePicker = Just (DateRangePicker.initialise doubleDateRangePickerConfig)
                , singleDateRangePicker_C = Just (DateRangePicker.initialise singleDateRangePickerConfig_C)
                , doubleDateRangePicker_C = Just (DateRangePicker.initialise doubleDateRangePickerConfig_C)
              }
            , Cmd.none
            )

        SingleDatePickerMsg subMsg ->
            case model.singleDatePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            DatePicker.update subMsg datePickerModel
                    in
                    ( { model | singleDatePicker = Just subModel }
                    , Cmd.map SingleDatePickerMsg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDatePickerMsg subMsg ->
            case model.doubleDatePicker of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            DatePicker.update subMsg datePickerModel
                    in
                    ( { model | doubleDatePicker = Just subModel }
                    , Cmd.map DoubleDatePickerMsg subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        SingleDatePickerMsg_C subMsg ->
            case model.singleDatePicker_C of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            DatePicker.update subMsg datePickerModel
                    in
                    ( { model | singleDatePicker_C = Just subModel }
                    , Cmd.map SingleDatePickerMsg_C subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDatePickerMsg_C subMsg ->
            case model.doubleDatePicker_C of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            DatePicker.update subMsg datePickerModel
                    in
                    ( { model | doubleDatePicker_C = Just subModel }
                    , Cmd.map DoubleDatePickerMsg_C subCmd
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

        SingleDateRangeMsg_C subMsg ->
            case model.singleDateRangePicker_C of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update subMsg datePickerModel
                    in
                    ( { model | singleDateRangePicker_C = Just subModel }
                    , Cmd.map SingleDateRangeMsg_C subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        DoubleDateRangeMsg_C subMsg ->
            case model.doubleDateRangePicker_C of
                Just datePickerModel ->
                    let
                        ( subModel, subCmd ) =
                            DateRangePicker.update subMsg datePickerModel
                    in
                    ( { model | doubleDateRangePicker_C = Just subModel }
                    , Cmd.map DoubleDateRangeMsg_C subCmd
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { today = Nothing

      --
      , singleDatePicker = Nothing
      , doubleDatePicker = Nothing
      , singleDatePicker_C = Nothing
      , doubleDatePicker_C = Nothing

      --
      , singleDateRangePicker = Nothing
      , doubleDateRangePicker = Nothing
      , singleDateRangePicker_C = Nothing
      , doubleDateRangePicker_C = Nothing
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
