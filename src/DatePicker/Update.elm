module DatePicker.Update exposing
    ( ExtMsg(..)
    , Model
    , Msg
    , initialise
    , update
    )

import Clock
import DatePicker.Internal.Update as Internal
    exposing
        ( Model(..)
        , Msg(..)
        , TimePickerState(..)
        )
import DatePicker.Types
    exposing
        ( CalendarConfig
        , DateLimit(..)
        , TimePickerConfig
        , ViewType(..)
        )
import DateTime exposing (DateTime)
import TimePicker.Update as TimePicker
import Utils.Actions exposing (fireAction)
import Utils.DateTime as DateTime


{-| The DatePicker Model.
-}
type alias Model =
    Internal.Model


{-| The DatePicker module's internal messages.
-}
type alias Msg =
    Internal.Msg


{-| The External messages that are being used to pass information to the
parent component. These messages are being returned by the update function
so that the consumer can pattern match on them.
-}
type ExtMsg
    = None
    | DateSelected (Maybe DateTime)


{-| Validates the primaryDate based on the dateLimit.
-}
validatePrimaryDate : CalendarConfig -> DateTime
validatePrimaryDate { today, primaryDate, dateLimit } =
    let
        date =
            -- Check if the user has specified a primaryDate. Otherwise use today as our primaryDate.
            Maybe.withDefault today primaryDate
    in
    case dateLimit of
        DateLimit { minDate, maxDate } ->
            let
                isBetweenConstrains =
                    DateTime.compareYearMonth minDate date == LT && DateTime.compareYearMonth maxDate date == GT
            in
            -- If there is a DateLimit and the date is between the constrains then proceed.
            -- If the date is outside of the constrains then set the primaryDate == minDate.
            if isBetweenConstrains then
                date

            else
                minDate

        NoLimit { disablePastDates } ->
            -- If we've disabled past dates and the `primaryDate` is a past date,
            -- set the primaryDate == today. Else proceed.
            if disablePastDates && DateTime.compareYearMonth date today == LT then
                today

            else
                date


{-| The initialisation function for the `DatePicker` module.
-}
initialise : ViewType -> CalendarConfig -> Maybe TimePickerConfig -> Model
initialise viewType ({ today, dateLimit } as calendarConfig) timePickerConfig =
    let
        ( primaryDate_, timePicker_ ) =
            let
                date =
                    validatePrimaryDate calendarConfig
            in
            case timePickerConfig of
                Just config ->
                    ( DateTime.setTime config.defaultTime date
                    , NotInitialised config
                    )

                Nothing ->
                    ( date
                    , NoTimePicker
                    )
    in
    Model
        { today = today
        , viewType = viewType
        , primaryDate = primaryDate_
        , selectedDate = Nothing
        , dateLimit = dateLimit
        , timePicker = timePicker_
        }


{-| The DatePicker's update function. Can be used in order to "wire up" the DatePicker
with the main application.
-}
update : Msg -> Model -> ( Model, Cmd Msg, ExtMsg )
update msg (Model model) =
    case msg of
        PreviousMonth ->
            ( Model { model | primaryDate = DateTime.decrementMonth model.primaryDate }
            , Cmd.none
            , None
            )

        NextMonth ->
            ( Model { model | primaryDate = DateTime.incrementMonth model.primaryDate }
            , Cmd.none
            , None
            )

        SelectDate date ->
            let
                -- Getting the time if it has already been selected
                -- by the user in order to update it on the newly
                -- selected date. For example: The user has selected
                -- 16 Sep 2019 21:00 but now they want to choose 17 Sep 2019.
                -- We maintain the time as 21:00 since they've already made
                -- this choice.
                ( time, cmd ) =
                    case model.timePicker of
                        TimePicker { timePicker } ->
                            ( TimePicker.getTime timePicker
                            , Cmd.none
                            )

                        _ ->
                            ( DateTime.getTime date
                            , fireAction InitialiseTimePicker
                            )

                updatedDate =
                    DateTime.setTime time date
            in
            case model.selectedDate of
                Just selected ->
                    if DateTime.getDate updatedDate == DateTime.getDate selected then
                        ( Model { model | selectedDate = Nothing }
                        , Cmd.none
                        , DateSelected Nothing
                        )

                    else
                        ( Model { model | selectedDate = Just updatedDate }
                        , cmd
                        , DateSelected (Just updatedDate)
                        )

                Nothing ->
                    ( Model { model | selectedDate = Just updatedDate }
                    , cmd
                    , DateSelected (Just updatedDate)
                    )

        MoveToToday ->
            ( Model { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            , None
            )

        InitialiseTimePicker ->
            let
                updatedModel =
                    case ( model.selectedDate, model.timePicker ) of
                        ( Just dateTime, NotInitialised { pickerType, defaultTime, pickerTitle } ) ->
                            let
                                timePicker =
                                    TimePicker
                                        { timePicker = TimePicker.initialise { time = defaultTime, pickerType = pickerType }
                                        , pickerTitle = pickerTitle
                                        }
                            in
                            { model | timePicker = timePicker }

                        _ ->
                            model
            in
            ( Model updatedModel
            , Cmd.none
            , None
            )

        TimePickerMsg subMsg ->
            case ( model.selectedDate, model.timePicker ) of
                ( Just date, TimePicker { timePicker, pickerTitle } ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePicker

                        updatedDate =
                            case extMsg of
                                TimePicker.UpdatedTime newTime ->
                                    Just (DateTime.setTime newTime date)

                                _ ->
                                    Just date
                    in
                    ( Model
                        { model
                            | selectedDate = updatedDate
                            , timePicker = TimePicker { timePicker = subModel, pickerTitle = pickerTitle }
                        }
                    , Cmd.map TimePickerMsg subCmd
                    , DateSelected updatedDate
                    )

                _ ->
                    ( Model model
                    , Cmd.none
                    , None
                    )
