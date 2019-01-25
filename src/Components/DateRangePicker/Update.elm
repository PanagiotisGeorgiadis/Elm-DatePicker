module Components.DateRangePicker.Update exposing
    ( ConstrainedModel
    , Constraints
    , DateConstrains(..)
    , Model
    , Model2(..)
    , Msg(..)
    , UnconstrainedModel
    , ViewType(..)
    , getPrimaryDate
    , getViewType
    , initialise
    , initialiseConstrainedCalendar2
    , initialiseUnconstrainedCalendar2
    , update
    , update2
    , updatePrimaryDate
    )

import DateTime.Clock as Clock
import DateTime.DateTime as DateTime exposing (DateTime)
import Models.Calendar exposing (DateLimit)
import Time as Time



{-
   Add shadowing enabled as a property which is going to be a Union type for that use.
   It will combine showOnHover and shadowRangeEnd properties. -- DateRange only.

   Keep viewType as a property with Union type. -- DatePicker && DateRange.

   Type the "model" as a Constrained and Uncostrained union type maybe as
   described below. -- DatePicker && DateRange.

   Implement minDateRangeOffset on the date range stuff. -- DateRange only.
-}
-- type Model_
--     = Constrained ConstrainedModel
--     | Unconstrained UnconstrainedModel
--
-- type DateConstrains
--     = Constrained Constraints
--     | Unconstrained
--
-- type alias Constraints =
--     { minDate : DateTime
--     , maxDate : DateTime
--     }
--
--
-- type alias StrippedModel =
--     { primaryDate : DateTime
--     , rangeStart : Maybe DateTime
--     , rangeEnd : Maybe DateTime
--     , shadowRangeEnd : Maybe DateTime
--     }
--
-- type alias ConstrainedModel =
--     { today : DateTime
--     , viewType : ViewType
--     , primaryDate : DateTime
--     , rangeStart : Maybe DateTime -- Do we need that ? Yes
--     , rangeEnd : Maybe DateTime -- Do we need that ? Yes
--     , shadowRangeEnd : Maybe DateTime
--
--     --
--     , showOnHover : Bool
--     -- , disablePastDates : Bool
--
--     -- , minDateRangeOffset : Int -- TODO
--     -- , pastDatesLimit : DateLimit
--     -- , futureDatesLimit : DateLimit
--     }
--
-- type alias UnconstrainedModel =
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
--     }
-- type Model =
--     | Constrained (Maybe Time) ConstrainedModel
--     | Unconstrained (Maybe Time) UnconstrainedModel
--
-- type alias ConstrainedModel = { viewType : ViewType, shadowingEnabled : ShadowType }
-- type alias UnconstrainedModel = { viewType : ViewType, shadowingEnabled : ShadowType }
--
-- type ShadowType
--     = Yes (Maybe DateTime)
--     | NoShadow
--
--
-- {- Extract to another file as a common type -}
-- type ViewType
--     = Single
--     | Double
--     -- | Shadowed Model
--     -- | Simplified Model
--     -- | SingleConstrained Model3
--     -- | DoubleConstrained Model4
--     -- | SingleWithTime
--     -- | DoubleWithTime
-- type alias Model =
--     { viewType : Single ShadowType | Double ShadowType
--     , shadowRangeEnd =
--     }
-- type ViewType
--     = Shadowed ModelX
--     | NotShadowed ModelY
--
-- type ViewType
--     = Single DateRangeModel
--     | Double DateRangeModel
--     | SingleConstrained ConstrainedModel
--     | DoubleConstrained ConstrainedModel
--     | SingleWithTime DateTimeModel
--     | DoubleWithTime DateTimeModel
--
--
-- type Model
--     = SingleDateRange Model
--     | DoubleDateRange Model
--     | SingleConstrained ConstrainedModel
--     | DoubleConstrained ConstrainedModel
--     | SingleWithTime DateTimeModel
--     | DoubleWithTime DateTimeModel


type ViewType
    = Single
    | Double


{-| type Model =
---- ShadowRangeModel {}
---- SimplifiedModel {}

Maybe do something like that on the initialise function here:
-- initialise : Config c -> Model
-- initialise { showOnHover } =
---- if showOnHover then
------ ShadowRangeModel
-------- {....
-------- , rangeStart : Nothing
-------- , rangeEnd : Nothing
-------- , shadowRangeEnd : Nothing
-------- .....
-------- }

---- else
------ SimplifiedModel
-------- {....
-------- }

So that you don't carry with you useless properties such as rangeStart, rangeEnd and shadowRangeEnd ?
If they are useless.

-}
type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime -- Do we need that ? Yes
    , rangeEnd : Maybe DateTime -- Do we need that ? Yes
    , shadowRangeEnd : Maybe DateTime

    --
    , showOnHover : Bool
    , disablePastDates : Bool

    -- , minDateRangeOffset : Int -- TODO
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    , constrainedDate : DateConstrains
    }


type DateConstrains
    = Constrained Constraints
    | Unconstrained


type alias Constraints =
    { minDate : DateTime
    , maxDate : DateTime
    }


type alias Config =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , showOnHover : Bool
    , disablePastDates : Bool

    -- , minDateRangeOffset : Int
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    , constrainedDate : DateConstrains
    }


initialise : Config -> Model
initialise { today, viewType, primaryDate, showOnHover, disablePastDates, pastDatesLimit, futureDatesLimit, constrainedDate } =
    case constrainedDate of
        Constrained { minDate, maxDate } ->
            { today = today
            , viewType = viewType
            , primaryDate = minDate
            , rangeStart = Nothing
            , rangeEnd = Nothing
            , shadowRangeEnd = Nothing

            --
            , showOnHover = showOnHover -- Maybe remove that and leave the onHover as a feature.
            , disablePastDates = disablePastDates -- You don't need that.

            -- , minDateRangeOffset = minDateRangeOffset
            --
            , pastDatesLimit = pastDatesLimit -- You don't need that.
            , futureDatesLimit = futureDatesLimit -- You don't need that.
            , constrainedDate = constrainedDate -- You don't need that.

            -- maybe add minDate && maxDate here or rething the dateLimitation ?
            }

        Unconstrained ->
            { today = today
            , viewType = viewType
            , primaryDate = primaryDate
            , rangeStart = Nothing
            , rangeEnd = Nothing
            , shadowRangeEnd = Nothing

            --
            , showOnHover = showOnHover -- Maybe remove that and leave the onHover as a feature.
            , disablePastDates = disablePastDates

            -- , minDateRangeOffset = minDateRangeOffset
            --
            , pastDatesLimit = pastDatesLimit
            , futureDatesLimit = futureDatesLimit
            , constrainedDate = constrainedDate -- You don't need that.
            }


type Model2
    = Constrained_ Constraints ConstrainedModel
    | Unconstrained_ UnconstrainedModel



-- type Props
--     = Constrained__ ConstrainedProps
--     | Unconstrained__ UnconstrainedProps


type alias ConstrainedModel =
    { today : DateTime -- Should belong in Props.
    , viewType : ViewType -- Should belong in Props.
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime
    , shadowRangeEnd : Maybe DateTime
    }


type alias ConstrainedCalendarConfig =
    { today : DateTime
    , viewType : ViewType

    -- , primaryDate : DateTime -- You don't need that in the constrained scenario.
    -- , disablePastDates : Bool -- You don't need that in the constrained scenario.
    }


initialiseConstrainedCalendar2 : ConstrainedCalendarConfig -> Constraints -> Model2
initialiseConstrainedCalendar2 { today, viewType } constraints =
    Constrained_ constraints
        { today = today
        , viewType = viewType
        , primaryDate = constraints.minDate
        , rangeStart = Nothing
        , rangeEnd = Nothing
        , shadowRangeEnd = Nothing
        }



-- {-| I think that it doesn't work and adds overhead. -}
-- type alias ConstrainedProps =
--     { today : DateTime
--     , viewType : ViewType
--     , disablePastDates : Bool
--     }
--
-- {-| I think that it doesn't work and adds overhead. -}
-- initialiseConstrainedCalendar : Constraints -> Model2
-- initialiseConstrainedCalendar constraints =
--     -- initialiseConstrainedCalendar : ConstrainedCalendarConfig -> Constraints -> Model2
--     -- initialiseConstrainedCalendar { today, viewType, disablePastDates } constraints =
--     Constrained_ constraints
--         -- { today = today
--         -- , viewType = viewType
--         -- , disablePastDates = disablePastDates
--         { primaryDate = constraints.minDate
--         , rangeStart = Nothing
--         , rangeEnd = Nothing
--         , shadowRangeEnd = Nothing
--         }


type alias UnconstrainedModel =
    { today : DateTime -- Should belong in Props.
    , viewType : ViewType -- Should belong in Props.
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime
    , shadowRangeEnd : Maybe DateTime
    , disablePastDates : Bool -- Should belong in Props.
    , pastDatesLimit : DateLimit -- Should belong in Props.
    , futureDatesLimit : DateLimit -- Should belong in Props.
    }


type alias UnconstrainedCalendarConfig =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , disablePastDates : Bool
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    }



-- {-| I think that it doesn't work and adds overhead. -}
-- type alias UnconstrainedProps =
--     { today : DateTime
--     , viewType : ViewType
--     , disablePastDates : Bool
--     , pastDatesLimit : DateLimit
--     , futureDatesLimit : DateLimit
--     }


initialiseUnconstrainedCalendar2 : UnconstrainedCalendarConfig -> Model2
initialiseUnconstrainedCalendar2 { today, viewType, primaryDate, disablePastDates, pastDatesLimit, futureDatesLimit } =
    Unconstrained_
        { today = today
        , viewType = viewType
        , primaryDate = primaryDate
        , rangeStart = Nothing
        , rangeEnd = Nothing
        , shadowRangeEnd = Nothing
        , disablePastDates = disablePastDates
        , pastDatesLimit = pastDatesLimit
        , futureDatesLimit = futureDatesLimit
        }



-- {-| I think that it doesn't work and adds overhead. -}
-- initialiseCalendar : { a | primaryDate : DateTime } -> Model2
-- initialiseCalendar { primaryDate } =
--     -- initialiseCalendar : UnconstrainedCalendarConfig -> Model2
--     -- initialiseCalendar { today, viewType, primaryDate, disablePastDates, pastDatesLimit, futureDatesLimit } =
--     Unconstrained_
--         -- { today = today
--         -- , viewType = viewType
--         -- , disablePastDates = disablePastDates
--         -- , pastDatesLimit = pastDatesLimit
--         -- , futureDatesLimit = futureDatesLimit
--         { primaryDate = primaryDate
--         , rangeStart = Nothing
--         , rangeEnd = Nothing
--         , shadowRangeEnd = Nothing
--         }
--
-- type alias Props p =
--     { p
--         | today : DateTime
--         , viewType : ViewType
--         , showOnHover : Bool
--         , disablePastDates : Bool
--         , pastDatesLimit : DateLimit
--         , futureDatesLimit : DateLimit
--     }
--
-- type alias TimeModel =
--     { selectedTime : Maybe Clock.Time
--     }
--
-- type Model__
--     = Constrained Constraint Model2 TimeModel
--     | Unconstrained Model2 TimeModel
--
-- type alias Model2 =
--     { primaryDate : DateTime
--     , rangeStart : Maybe DateTime
--     , rangeEnd : Maybe DateTime
--     , shadowRangeEnd : Maybe DateTime
--     }


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
                                    { model_ | rangeEnd = Just date }

                                EQ ->
                                    -- Cancels out the selected date.
                                    { model_ | rangeStart = Nothing, rangeEnd = Nothing }

                                GT ->
                                    -- Reversed case. ie. the user selected the rangeEnd first.
                                    { model_ | rangeStart = Just date, rangeEnd = Just start }

                        ( Nothing, Just end ) ->
                            -- Some imposible state
                            { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Just start, Just end ) ->
                            -- Resetting the date range here
                            { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Nothing, Nothing ) ->
                            -- Starting the date range process.
                            { model_ | rangeStart = Just date }
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


update2 : Msg -> Model2 -> ( Model2, Cmd Msg )
update2 msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        PreviousMonth ->
            ( updatePrimaryDate (DateTime.getPreviousMonth (getPrimaryDate model)) model
            , Cmd.none
            )

        NextMonth ->
            ( updatePrimaryDate (DateTime.getNextMonth (getPrimaryDate model)) model
            , Cmd.none
            )

        SelectDate date ->
            let
                model_ =
                    -- { model | shadowRangeEnd = Nothing }
                    updateShadowRangeEnd Nothing model

                ( rangeStart, rangeEnd ) =
                    ( getRangeStart model
                    , getRangeEnd model
                    )

                updateFn =
                    case ( rangeStart, rangeEnd ) of
                        ( Just start, Nothing ) ->
                            -- Date Range Complete
                            case DateTime.compareDates start date of
                                LT ->
                                    -- Normal case.
                                    -- { model_ | rangeEnd = Just date }
                                    updateRangeEnd (Just date)

                                EQ ->
                                    -- Cancels out the selected date.
                                    -- { model_ | rangeStart = Nothing, rangeEnd = Nothing }
                                    updateRangeStart Nothing << updateRangeEnd Nothing

                                GT ->
                                    -- Reversed case. ie. the user selected the rangeEnd first.
                                    -- { model_ | rangeStart = Just date, rangeEnd = Just start }
                                    updateRangeStart (Just date) << updateRangeEnd (Just start)

                        ( Nothing, Just end ) ->
                            -- Some imposible state
                            -- { model_ | rangeStart = Just date, rangeEnd = Nothing }
                            updateRangeStart (Just date) << updateRangeEnd Nothing

                        ( Just start, Just end ) ->
                            -- Resetting the date range here
                            -- { model_ | rangeStart = Just date, rangeEnd = Nothing }
                            updateRangeStart (Just date) << updateRangeEnd Nothing

                        ( Nothing, Nothing ) ->
                            -- Starting the date range process.
                            -- { model_ | rangeStart = Just date }
                            updateRangeStart (Just date)
            in
            ( updateFn model_
            , Cmd.none
            )

        DateHoverDetected date ->
            let
                ( rangeStart, rangeEnd ) =
                    ( getRangeStart model
                    , getRangeEnd model
                    )
            in
            case ( rangeStart, rangeEnd ) of
                ( Just start, Nothing ) ->
                    ( updateShadowRangeEnd (Just date) model
                    , Cmd.none
                    )

                _ ->
                    ( updateShadowRangeEnd Nothing model
                    , Cmd.none
                    )

        ResetShadowDateRange ->
            ( updateShadowRangeEnd Nothing model
            , Cmd.none
            )


updatePrimaryDate : DateTime -> Model2 -> Model2
updatePrimaryDate val model =
    case model of
        Constrained_ constraint model_ ->
            Constrained_ constraint { model_ | primaryDate = val }

        Unconstrained_ model_ ->
            Unconstrained_ { model_ | primaryDate = val }


updateRangeStart : Maybe DateTime -> Model2 -> Model2
updateRangeStart val model =
    case model of
        Constrained_ constraint model_ ->
            Constrained_ constraint { model_ | rangeStart = val }

        Unconstrained_ model_ ->
            Unconstrained_ { model_ | rangeStart = val }


updateRangeEnd : Maybe DateTime -> Model2 -> Model2
updateRangeEnd val model =
    case model of
        Constrained_ constraint model_ ->
            Constrained_ constraint { model_ | rangeEnd = val }

        Unconstrained_ model_ ->
            Unconstrained_ { model_ | rangeEnd = val }


updateShadowRangeEnd : Maybe DateTime -> Model2 -> Model2
updateShadowRangeEnd val model =
    case model of
        Constrained_ constraint model_ ->
            Constrained_ constraint { model_ | shadowRangeEnd = val }

        Unconstrained_ model_ ->
            Unconstrained_ { model_ | shadowRangeEnd = val }


getPrimaryDate : Model2 -> DateTime
getPrimaryDate model =
    case model of
        Constrained_ constraint { primaryDate } ->
            primaryDate

        Unconstrained_ { primaryDate } ->
            primaryDate


getRangeStart : Model2 -> Maybe DateTime
getRangeStart model =
    case model of
        Constrained_ constraint { rangeStart } ->
            rangeStart

        Unconstrained_ { rangeStart } ->
            rangeStart


getRangeEnd : Model2 -> Maybe DateTime
getRangeEnd model =
    case model of
        Constrained_ constraint { rangeEnd } ->
            rangeEnd

        Unconstrained_ { rangeEnd } ->
            rangeEnd


getViewType : Model2 -> ViewType
getViewType model =
    case model of
        Constrained_ constraint { viewType } ->
            viewType

        Unconstrained_ { viewType } ->
            viewType
