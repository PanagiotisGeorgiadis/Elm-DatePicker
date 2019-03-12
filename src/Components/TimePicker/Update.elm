module Components.TimePicker.Update exposing
    ( ExtMsg(..)
    , Model
    , Msg
    , getPickerTypeString
    , getTime
    , initialise
    , toHumanReadableTime
    , update
    , updateDisplayTime
    )

import Clock
import Components.TimePicker.Internal.Update as Internal
    exposing
        ( InternalModel
        , Model(..)
        , Msg(..)
        )
import Components.TimePicker.Types exposing (PickerType(..), TimeParts(..))


{-| The TimePicker Model
-}
type alias Model =
    Internal.Model


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
    Model
        { pickerType = pickerType
        , time = time
        , hours = toHoursString time
        , minutes = toMinutesString time
        , seconds = toSecondsString time
        , milliseconds = toMillisecondsString time
        }


{-| An alias of the TimePicker internal messages.
-}
type alias Msg =
    Internal.Msg


{-| The External messages that are being used to transform information to the
parent component.
-}
type ExtMsg
    = None
    | UpdatedTime Clock.Time


update : Msg -> Model -> ( Model, Cmd Msg, ExtMsg )
update msg (Model model) =
    case msg of
        InputHandler timePart value ->
            let
                updatedModel =
                    case timePart of
                        Hours ->
                            Model { model | hours = validateHours model value }

                        Minutes ->
                            Model { model | minutes = validateMinutes model value }

                        Seconds ->
                            Model { model | seconds = validateSeconds model value }

                        Milliseconds ->
                            Model { model | milliseconds = validateMilliseconds model value }
            in
            ( updatedModel
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
                    ( Model { model | time = time, hours = toHoursString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( Model model
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
                    ( Model { model | time = time, minutes = toMinutesString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( Model model
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
                    ( Model { model | time = time, seconds = toSecondsString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( Model model
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
                    ( Model { model | time = time, milliseconds = toMillisecondsString time }
                    , Cmd.none
                    , UpdatedTime time
                    )

                Nothing ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        Increment timePart ->
            let
                ( updateFn, step ) =
                    case timePart of
                        Hours ->
                            ( Tuple.first << Clock.incrementHours
                            , getHoursStep model
                            )

                        Minutes ->
                            ( Tuple.first << Clock.incrementMinutes
                            , getMinutesStep model
                            )

                        Seconds ->
                            ( Tuple.first << Clock.incrementSeconds
                            , getSecondsStep model
                            )

                        Milliseconds ->
                            ( Tuple.first << Clock.incrementMilliseconds
                            , getMillisecondsStep model
                            )

                time =
                    stepThrough
                        { n = step
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time (Model model)
            , Cmd.none
            , UpdatedTime time
            )

        Decrement timePart ->
            let
                ( updateFn, step ) =
                    case timePart of
                        Hours ->
                            ( Tuple.first << Clock.decrementHours
                            , getHoursStep model
                            )

                        Minutes ->
                            ( Tuple.first << Clock.decrementMinutes
                            , getMinutesStep model
                            )

                        Seconds ->
                            ( Tuple.first << Clock.decrementSeconds
                            , getSecondsStep model
                            )

                        Milliseconds ->
                            ( Tuple.first << Clock.decrementMilliseconds
                            , getMillisecondsStep model
                            )

                time =
                    stepThrough
                        { n = step
                        , time = model.time
                        , updateFn = updateFn
                        }
            in
            ( updateDisplayTime time (Model model)
            , Cmd.none
            , UpdatedTime time
            )


{-| Validates the String representation of `Hour` given from the time-input.
-}
validateHours : InternalModel -> String -> String
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
validateMinutes : InternalModel -> String -> String
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
validateSeconds : InternalModel -> String -> String
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
validateMilliseconds : InternalModel -> String -> String
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
updateDisplayTime time (Model model) =
    Model
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


{-| Formats `Hours`, `Minutes`, `Seconds` to a representation String.

    timeToString 0 -- "00" : String

    timeToString 30 -- "30" : String

-}
timeToString : Int -> String
timeToString time =
    if time < 10 then
        "0" ++ String.fromInt time

    else
        String.fromInt time


{-| Formats `Milliseconds` to a representation String.

    millisToString 1 -- "001" : String

    millisToString 10 -- "010" : String

    millisToString 100 -- "100" : String

-}
millisToString : Int -> String
millisToString millis =
    if millis < 10 then
        "00" ++ String.fromInt millis

    else if millis < 100 then
        "0" ++ String.fromInt millis

    else
        String.fromInt millis


{-| Extracts the `hoursStep` from the Model
-}
getHoursStep : InternalModel -> Int
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
getMinutesStep : InternalModel -> Int
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
getSecondsStep : InternalModel -> Int
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
-}
getMillisecondsStep : InternalModel -> Int
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


{-| The parameters defined for usage with the stepThrough function.
-}
type alias SteppingParams =
    { n : Int
    , updateFn : Clock.Time -> Clock.Time
    , time : Clock.Time
    }


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


{-| Helper function that returns the Clock.Time stored in the TimePicker's model.
-}
getTime : Model -> Clock.Time
getTime (Model { time }) =
    time


{-| Returns a string based on the pickerType specified in the module's Model.
-}
getPickerTypeString : Model -> String
getPickerTypeString (Model { pickerType }) =
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
toHumanReadableTime (Model { pickerType, hours, minutes, seconds, milliseconds }) =
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
