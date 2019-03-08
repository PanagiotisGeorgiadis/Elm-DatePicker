module Components.TimePicker.Update exposing
    ( ExtMsg(..)
    , Model
    , Msg(..)
    , PickerType(..)
    , getPickerTypeString
    , getTime
    , initialise
    , toHumanReadableTime
    , update
    , updateDisplayTime
    )

import Clock
import Utils.Time exposing (millisToString, timeToString)


{-| Describes different picker types.
-}
type PickerType
    = HH { hoursStep : Int }
    | HH_MM { hoursStep : Int, minutesStep : Int }
    | HH_MM_SS { hoursStep : Int, minutesStep : Int, secondsStep : Int }
    | HH_MM_SS_MMMM { hoursStep : Int, minutesStep : Int, secondsStep : Int, millisecondsStep : Int }


{-| The TimePicker Model
-}
type alias Model =
    { time : Clock.Time
    , pickerType : PickerType
    , hours : String
    , minutes : String
    , seconds : String
    , milliseconds : String
    }


{-| The Config needed to create a TimePicker.Model
-}
type alias Config =
    { time : Clock.Time
    , pickerType : PickerType
    }


{-| Initialisation function
-}
initialise : Config -> Model
initialise { pickerType, time } =
    { pickerType = pickerType
    , time = time
    , hours = toHoursString time
    , minutes = toMinutesString time
    , seconds = toSecondsString time
    , milliseconds = toMillisecondsString time
    }


type Msg
    = HoursInputHandler String
    | MinutesInputHandler String
    | SecondsInputHandler String
    | MillisecondsInputHandler String
    | UpdateHours String
    | UpdateMinutes String
    | UpdateSeconds String
    | UpdateMilliseconds String
    | IncrementHours
    | IncrementMinutes
    | IncrementSeconds
    | IncrementMilliseconds
    | DecrementHours
    | DecrementMinutes
    | DecrementSeconds
    | DecrementMilliseconds


type ExtMsg
    = None
    | UpdatedTime Clock.Time


update : Msg -> Model -> ( Model, Cmd Msg, ExtMsg )
update msg model =
    case msg of
        HoursInputHandler value ->
            ( { model | hours = validateHours model value }
            , Cmd.none
            , None
            )

        MinutesInputHandler value ->
            ( { model | minutes = validateMinutes model value }
            , Cmd.none
            , None
            )

        SecondsInputHandler value ->
            ( { model | seconds = validateSeconds model value }
            , Cmd.none
            , None
            )

        MillisecondsInputHandler value ->
            ( { model | milliseconds = validateMilliseconds model value }
            , Cmd.none
            , None
            )

        UpdateHours hours ->
            let
                updatedTime =
                    Maybe.andThen (\h -> Clock.setHours h model.time) (String.toInt hours)
            in
            case updatedTime of
                Just time ->
                    ( { model | time = time, hours = toHoursString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    , None
                    )

        UpdateMinutes value ->
            let
                updatedTime =
                    Maybe.andThen (\m -> Clock.setMinutes m model.time) (String.toInt value)
            in
            case updatedTime of
                Just time ->
                    ( { model | time = time, minutes = toMinutesString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    , None
                    )

        UpdateSeconds value ->
            let
                updatedTime =
                    Maybe.andThen (\s -> Clock.setSeconds s model.time) (String.toInt value)
            in
            case updatedTime of
                Just time ->
                    ( { model | time = time, seconds = toSecondsString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    , None
                    )

        UpdateMilliseconds value ->
            let
                updatedTime =
                    Maybe.andThen (\m -> Clock.setMilliseconds m model.time) (String.toInt value)
            in
            case updatedTime of
                Just time ->
                    ( { model | time = time, milliseconds = toMillisecondsString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    , None
                    )

        IncrementHours ->
            let
                updateFn =
                    Tuple.first << Clock.incrementHours

                time =
                    stepThrough
                        { n = getHoursStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        IncrementMinutes ->
            let
                updateFn =
                    Tuple.first << Clock.incrementMinutes

                time =
                    stepThrough
                        { n = getMinutesStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        IncrementSeconds ->
            let
                updateFn =
                    Tuple.first << Clock.incrementSeconds

                time =
                    stepThrough
                        { n = getSecondsStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        IncrementMilliseconds ->
            let
                updateFn =
                    Tuple.first << Clock.incrementMilliseconds

                time =
                    stepThrough
                        { n = getMillisecondsStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        DecrementHours ->
            let
                updateFn =
                    Tuple.first << Clock.decrementHours

                time =
                    stepThrough
                        { n = getHoursStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        DecrementMinutes ->
            let
                updateFn =
                    Tuple.first << Clock.decrementMinutes

                time =
                    stepThrough
                        { n = getMinutesStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        DecrementSeconds ->
            let
                updateFn =
                    Tuple.first << Clock.decrementSeconds

                time =
                    stepThrough
                        { n = getSecondsStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )

        DecrementMilliseconds ->
            let
                updateFn =
                    Tuple.first << Clock.decrementMilliseconds

                time =
                    stepThrough
                        { n = getMillisecondsStep model
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time model
            , Cmd.none
            , UpdatedTime time
            )


{-| Validates the String representation of `Hour` given from the time-input.
-}
validateHours : Model -> String -> String
validateHours { hours } newValue =
    let
        sanitisedValue =
            filterNonDigits newValue
    in
    validateTimeSegment
        { default = hours
        , new = sanitisedValue
        , ceil = 24
        }


{-| Validates the String representation of `Minute` given from the time-input.
-}
validateMinutes : Model -> String -> String
validateMinutes { minutes } newValue =
    let
        sanitisedValue =
            filterNonDigits newValue
    in
    validateTimeSegment
        { default = minutes
        , new = sanitisedValue
        , ceil = 60
        }


{-| Validates the String representation of `Second` given from the time-input.
-}
validateSeconds : Model -> String -> String
validateSeconds { seconds } newValue =
    let
        sanitisedValue =
            filterNonDigits newValue
    in
    validateTimeSegment
        { default = seconds
        , new = sanitisedValue
        , ceil = 60
        }


{-| Validates the String representation of `Millisecond` given from the time-input.
-}
validateMilliseconds : Model -> String -> String
validateMilliseconds { milliseconds } newValue =
    let
        sanitisedValue =
            filterNonDigits newValue
    in
    validateTimeSegment
        { default = milliseconds
        , new = sanitisedValue
        , ceil = 1000
        }


{-| Generic validation parameters used by validateTimeSegment
-}
type alias ValidationParams =
    { default : String
    , new : String
    , ceil : Int
    }


{-| Generic validation function used by validateHours, validateMinutes, validateSeconds and validateMilliseconds functions.
-}
validateTimeSegment : ValidationParams -> String
validateTimeSegment { default, new, ceil } =
    case String.toInt new of
        Just v ->
            if v >= 0 && v < ceil then
                new

            else
                default

        Nothing ->
            if String.isEmpty new then
                new

            else
                default


{-| Filters out the non-digit characters from the input
-}
filterNonDigits : String -> String
filterNonDigits =
    String.fromList << List.filter Char.isDigit << String.toList


{-| Updates the time property in the TimePicker Model
-}
updateDisplayTime : Clock.Time -> Model -> Model
updateDisplayTime time model =
    { model
        | time = time
        , hours = toHoursString time
        , minutes = toMinutesString time
        , seconds = toSecondsString time
        , milliseconds = toMillisecondsString time
    }


{-| Returns the formatted `Hour` string from a Clock.Time
-}
toHoursString : Clock.Time -> String
toHoursString =
    timeToString << Clock.getHours


{-| Returns the formatted `Minute` string from a Clock.Time
-}
toMinutesString : Clock.Time -> String
toMinutesString =
    timeToString << Clock.getMinutes


{-| Returns the formatted `Second` string from a Clock.Time
-}
toSecondsString : Clock.Time -> String
toSecondsString =
    timeToString << Clock.getSeconds


{-| Returns the formatted `Millisecond` string from a Clock.Time
-}
toMillisecondsString : Clock.Time -> String
toMillisecondsString =
    millisToString << Clock.getMilliseconds


type alias SteppingParams =
    { n : Int
    , updateFn : Clock.Time -> Clock.Time
    , time : Clock.Time
    }


{-| Extracts the `hoursStep` from the Model
-}
getHoursStep : Model -> Int
getHoursStep { pickerType } =
    case pickerType of
        HH { hoursStep } ->
            hoursStep

        HH_MM { hoursStep } ->
            hoursStep

        HH_MM_SS { hoursStep } ->
            hoursStep

        HH_MM_SS_MMMM { hoursStep } ->
            hoursStep


{-| Extracts the `minutesStep` from the Model or uses a `defaultValue` on the `Invalid State` cases.
-}
getMinutesStep : Model -> Int
getMinutesStep { pickerType } =
    case pickerType of
        HH _ ->
            1

        HH_MM { minutesStep } ->
            minutesStep

        HH_MM_SS { minutesStep } ->
            minutesStep

        HH_MM_SS_MMMM { minutesStep } ->
            minutesStep


{-| Extracts the `secondsStep` from the Model or uses a `defaultValue` on the `Invalid State` cases.
-}
getSecondsStep : Model -> Int
getSecondsStep { pickerType } =
    case pickerType of
        HH _ ->
            1

        HH_MM _ ->
            1

        HH_MM_SS { secondsStep } ->
            secondsStep

        HH_MM_SS_MMMM { secondsStep } ->
            secondsStep


{-| Extracts the `millisecondsStep` from the Model or uses a `defaultValue` on the `Invalid State` cases.

    Internal

-}
getMillisecondsStep : Model -> Int
getMillisecondsStep { pickerType } =
    case pickerType of
        HH _ ->
            1

        HH_MM _ ->
            1

        HH_MM_SS _ ->
            1

        HH_MM_SS_MMMM { millisecondsStep } ->
            millisecondsStep


{-| Increments / Decrements time units (based on the updateFn) recursively
and returns the updated time. This is based on the stepSize ( n ), the
increment / decrement function ( updateFn ) and the initial time given.

Example:

    stepThrough { n = 5, updateFn = Clock.incrementMinutes, time = 21:00 } -> 21:05

    Internal

-}
stepThrough : SteppingParams -> Clock.Time
stepThrough { n, updateFn, time } =
    let
        ( time_, n_ ) =
            ( updateFn time
            , n - 1
            )
    in
    if n_ <= 0 then
        time_

    else
        stepThrough
            { n = n_
            , time = time_
            , updateFn = updateFn
            }


{-| Exposed
-}
getTime : Model -> Clock.Time
getTime { time } =
    time


{-| Transforms the pickerType to String.
-}
getPickerTypeString : Model -> String
getPickerTypeString { pickerType } =
    case pickerType of
        HH _ ->
            "hh"

        HH_MM _ ->
            "hh_mm"

        HH_MM_SS _ ->
            "hh_mm_ss"

        HH_MM_SS_MMMM _ ->
            "hh_mm_ss_mmmm"


{-| Transforms a time to its human readable representation based
on the `PickerType` that was defined.
-}
toHumanReadableTime : Model -> String
toHumanReadableTime { pickerType, hours, minutes, seconds, milliseconds } =
    case pickerType of
        HH _ ->
            hours

        HH_MM _ ->
            String.join ":" [ hours, minutes ]

        HH_MM_SS _ ->
            String.join ":" [ hours, minutes, seconds ]

        HH_MM_SS_MMMM _ ->
            String.join "."
                [ String.join ":" [ hours, minutes, seconds ]
                , milliseconds
                ]
