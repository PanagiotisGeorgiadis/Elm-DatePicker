module DatePicker exposing
    ( Model, Msg, ExtMsg(..)
    , setSelectedDate, resetSelectedDate
    , initialise, update, view
    )

{-| The `DatePicker` component is a DatePicker that allows the user to
select a **single date**. It has its own [Model](DatePicker#Model)
and [Msg](DatePicker#Msg) types which handle the rendering and date
selection functionalities. It also exposes a list of **external messages**
( [ExtMsg](DatePicker#ExtMsg) ) which can be used by the consumer to extract the **selected date**.
You can see a simple `DatePicker` application in
[this ellie-app example](https://ellie-app.com/new) or you can clone [this
example repository](https://github.com/PanagiotisGeorgiadis/).

@docs Model, Msg, ExtMsg

@docs setSelectedDate, resetSelectedDate

@docs initialise, update, view

-}

import Clock
import DatePicker.I18n exposing (I18n)
import DatePicker.Internal.I18n exposing (defaultI18n)
import DatePicker.Internal.Update as Internal
    exposing
        ( Model(..)
        , Msg(..)
        , TimePickerState(..)
        )
import DatePicker.Internal.View as Internal
import DatePicker.Types
    exposing
        ( CalendarConfig
        , DateLimit(..)
        , TimePickerConfig
        , ViewType(..)
        )
import DateTime exposing (DateTime)
import Html exposing (Html)
import TimePicker.Update as TimePicker
import Utils.DateTime as DateTime


{-| The `DatePicker` Model.
-}
type alias Model =
    Internal.Model


{-| The internal messages that are being used by the `DatePicker`. You can map
this message with your own message in order to "wire up" the `DatePicker` with your
application. Example of wiring up:

    import DatePicker

    type Msg
        = DatePickerMsg DatePicker.Msg

    DatePickerMsg subMsg ->
        let
            (subModel, subCmd, extMsg) =
                DatePicker.update subMsg model.datePicker

            selectedDateTime =
                case extMsg of
                    DatePicker.DateSelected dateTime ->
                        dateTime

                    DatePicker.None ->
                        Nothing
        in
        ( { model | datePicker = subModel }
        , Cmd.map DatePickerMsg subCmd
        )

-}
type alias Msg =
    Internal.Msg


{-| The _**external messages**_ that are being used to pass information to the
parent component. These messages are being returned by the [update function](DatePicker#update)
so that the consumer can pattern match on them and get the selected `DateTime`.
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
            -- Check if the user has specified a primaryDate.
            -- Otherwise use today's date as our primaryDate
            -- with the time set to midnight.
            case primaryDate of
                Just d ->
                    d

                Nothing ->
                    DateTime.setTime Clock.midnight today
    in
    case dateLimit of
        DateLimit { minDate, maxDate } ->
            let
                isBetweenConstrains =
                    (DateTime.compareYearMonth minDate date == LT || DateTime.compareYearMonth minDate date == EQ)
                        && (DateTime.compareYearMonth maxDate date == GT || DateTime.compareYearMonth maxDate date == EQ)
            in
            -- If there is a DateLimit and the date is between the constrains then proceed.
            -- If the date is outside of the constrains then set the primaryDate == minDate.
            if isBetweenConstrains then
                date

            else
                minDate

        NoLimit ->
            date


{-| The initialisation function of the `DatePicker`.

    import Clock
    import DatePicker
    import DateTime
    import Time exposing (Month(..))
    import TimePicker.Types as TimePicker

    myInitialise : DateTime -> DatePicker.Model
    myInitialise today =
        let
            ( date1, date2 ) =
                ( DateTime.fromRawParts { day = 1, month = Jan, year = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                , DateTime.fromRawParts { day = 31, month = Dec, year = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                )

            calendarConfig =
                { today = today
                , primaryDate = Nothing
                , dateLimit =
                    case ( date1, date2 ) of
                        ( Just d1, Just d2 ) ->
                            DateLimit { minDate = d1, maxDate = d2 }

                        _ ->
                            NoLimit
                }

            timePickerConfig =
                Just
                    { pickerType = TimePicker.HH_MM { hoursStep = 1, minutesStep = 5 }
                    , defaultTime = Clock.midnight
                    , pickerTitle = "Date Time"
                    }
        in
        DatePicker.initialise DatePicker.Single calendarConfig timePickerConfig Nothing

-}
initialise : ViewType -> CalendarConfig -> Maybe TimePickerConfig -> Maybe I18n -> Model
initialise viewType ({ today, dateLimit, startingWeekday } as calendarConfig) timePickerConfig i18n =
    let
        ( primaryDate_, timePicker_ ) =
            let
                date =
                    validatePrimaryDate calendarConfig
            in
            case timePickerConfig of
                Just { pickerType, defaultTime, pickerTitle } ->
                    ( DateTime.setTime defaultTime date
                    , TimePicker
                        { timePicker = TimePicker.initialise { time = defaultTime, pickerType = pickerType }
                        , pickerTitle = pickerTitle
                        }
                    )

                Nothing ->
                    ( date
                    , NoTimePicker
                    )
    in
    Model
        { today = today
        , viewType = viewType
        , startingWeekday = startingWeekday
        , primaryDate = primaryDate_
        , selectedDate = Nothing
        , dateLimit = dateLimit
        , timePicker = timePicker_
        , i18n =
            case i18n of
                Just i18n_ ->
                    i18n_

                Nothing ->
                    defaultI18n
        }


{-| The `DatePicker's` update function. Can be used in order to "wire up" the `DatePicker`
with the **main application** as shown in the example of the [DatePicker.Msg](DatePicker#Msg).
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
                            , Cmd.none
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

        TimePickerMsg subMsg ->
            case model.timePicker of
                TimePicker { timePicker, pickerTitle } ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePicker

                        updatedDate =
                            case model.selectedDate of
                                Just date ->
                                    case extMsg of
                                        TimePicker.UpdatedTime newTime ->
                                            Just (DateTime.setTime newTime date)

                                        _ ->
                                            model.selectedDate

                                Nothing ->
                                    model.selectedDate
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


{-| The `DatePicker` view.
-}
view : Model -> Html Msg
view =
    Internal.view


{-| Sets the date that's marked as selected.
-}
setSelectedDate : DateTime -> Model -> Model
setSelectedDate date (Model model) =
    Model { model | selectedDate = Just date }


{-| Removes the date selection.
-}
resetSelectedDate : Model -> Model
resetSelectedDate (Model model) =
    Model { model | selectedDate = Nothing }
