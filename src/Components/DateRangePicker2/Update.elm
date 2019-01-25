module Components.DateRangePicker2.Update exposing
    ( DateLimit(..)
    , DateRangeOffset(..)
    , Model
    , Msg(..)
    , Shadowing(..)
    , ViewType(..)
    , initialise
    , update
    )

import DateTime.DateTime as DateTime exposing (DateTime)
import Models.Calendar as Calendar



-- Minimum Days from today
-- ^^^^^^^^
-- This can be implemented with the DateLimit.
-- Example: DateLimit { minDate = (DateTime.incrementDay todayDateTime) + numberOfDays we want, }
--
-- Minimum Days from given day.


type ViewType
    = Single
    | Double



-- = Single
-- | Double
-- | SingleWithTime
-- | DoubleWithTime


type DateRangeOffset
    = Offset OffsetConfig
    | NoOffset


type alias OffsetConfig =
    { invalidDates : List DateTime
    , minDateRangeLength : Int
    }


type DateLimit
    = DateLimit DateLimitation
    | NoLimit NoLimitConfig



-- | YearLimit YearLimitation -- Maybe remove this ?
-- | MonthLimit MonthLimitation -- Maybe remove this ?
-- type alias YearLimitation =
--     { pastYears : Int
--     , futureYears : Int
--     , disablePastDates : Bool
--     }
--
--
-- type alias MonthLimitation =
--     { pastMonths : Int
--     , futureMonths : Int
--     , disablePastDates : Bool
--     }


type alias DateLimitation =
    { minDate : DateTime
    , maxDate : DateTime
    }


type alias NoLimitConfig =
    { disablePastDates : Bool
    }


type Shadowing
    = Enabled (Maybe DateTime)
    | Disabled



-- type alias Model =
--     { today : DateTime
--     , viewType : ViewType
--     , primaryDate : DateTime
--     , rangeStart : Maybe DateTime -- Do we need that ? Yes
--     , rangeEnd : Maybe DateTime -- Do we need that ? Yes
--     , shadowRangeEnd : Maybe DateTime
--
--     --
--     , showOnHover : Bool
--     , disablePastDates : Bool
--
--     -- , minDateRangeOffset : Int -- TODO
--     , pastDatesLimit : DateLimit
--     , futureDatesLimit : DateLimit
--     , constrainedDate : DateConstrains
--     }


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime
    , shadowRangeEnd : Maybe DateTime

    -- , showOnHover : Shadowing -- TODO: Think about that ?
    , dateLimit : DateLimit
    , dateRangeOffset : DateRangeOffset
    }


type alias DateRangeConfig =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit

    -- , showOnHover : Shadowing
    }


initialise : DateRangeConfig -> Model
initialise { today, viewType, primaryDate, dateLimit } =
    let
        primaryDate_ =
            case dateLimit of
                DateLimit { minDate } ->
                    minDate

                _ ->
                    primaryDate
    in
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate_
    , rangeStart = Nothing
    , rangeEnd = Nothing
    , shadowRangeEnd = Nothing
    , dateLimit = dateLimit

    -- , dateRangeOffset = NoOffset
    , dateRangeOffset = Offset { minDateRangeLength = 7, invalidDates = [] }
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | DateHoverDetected DateTime
    | ResetShadowDateRange


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        PreviousMonth ->
            ( { model | primaryDate = DateTime.getPreviousMonth model.primaryDate }
            , Cmd.none
            )

        NextMonth ->
            ( { model | primaryDate = DateTime.getNextMonth model.primaryDate }
            , Cmd.none
            )

        SelectDate date ->
            let
                model_ =
                    { model | shadowRangeEnd = Nothing }

                updatedModel =
                    case ( model.rangeStart, model.rangeEnd ) of
                        ( Just start, Nothing ) ->
                            -- Date Range Complete
                            case DateTime.compareDates start date of
                                LT ->
                                    -- Normal case.
                                    updateDateRangeOffset { model_ | rangeEnd = Just date }

                                EQ ->
                                    -- Cancels out the selected date.
                                    updateDateRangeOffset { model_ | rangeStart = Nothing, rangeEnd = Nothing }

                                GT ->
                                    -- Reversed case. ie. the user selected the rangeEnd first.
                                    updateDateRangeOffset { model_ | rangeStart = Just date, rangeEnd = Just start }

                        ( Nothing, Just end ) ->
                            -- Some imposible state
                            updateDateRangeOffset { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Just start, Just end ) ->
                            -- Resetting the date range here
                            updateDateRangeOffset { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Nothing, Nothing ) ->
                            -- Starting the date range process.
                            updateDateRangeOffset { model_ | rangeStart = Just date }
            in
            ( updatedModel
            , Cmd.none
            )

        DateHoverDetected date ->
            case ( model.rangeStart, model.rangeEnd ) of
                ( Just start, Nothing ) ->
                    ( { model | shadowRangeEnd = Just date }
                    , Cmd.none
                    )

                _ ->
                    ( { model | shadowRangeEnd = Nothing }
                    , Cmd.none
                    )

        ResetShadowDateRange ->
            ( { model | shadowRangeEnd = Nothing }
            , Cmd.none
            )


updateDateRangeOffset : Model -> Model
updateDateRangeOffset ({ rangeStart, rangeEnd, dateRangeOffset } as model) =
    case dateRangeOffset of
        Offset { minDateRangeLength } ->
            case ( rangeStart, rangeEnd ) of
                ( Just start, Nothing ) ->
                    let
                        invalidFutureDates =
                            List.filter ((/=) start) <|
                                List.reverse <|
                                    List.drop 1 <|
                                        List.reverse <|
                                            DateTime.getDateRange start (Calendar.incrementDays (minDateRangeLength - 1) start)

                        invalidPastDates =
                            List.filter ((/=) start) <|
                                List.reverse <|
                                    List.drop 1 <|
                                        DateTime.getDateRange start (Calendar.decrementDays (minDateRangeLength - 1) start)

                        invalidDates =
                            invalidFutureDates ++ invalidPastDates
                    in
                    { model
                        | dateRangeOffset = Offset (OffsetConfig invalidDates minDateRangeLength)
                    }

                _ ->
                    { model
                        | dateRangeOffset = Offset (OffsetConfig [] minDateRangeLength)
                    }

        NoOffset ->
            model
