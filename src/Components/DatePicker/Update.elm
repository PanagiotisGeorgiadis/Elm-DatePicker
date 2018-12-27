module Components.DatePicker.Update exposing (..)


import Time
import DateTime.Calendar as Calendar
import Models.Calendar exposing (CalendarModel)

import Components.SingleDatePicker.Update as SingleDatePicker

type alias Model =
    { today: Calendar.Date
    , primaryDate : Calendar.Date
    -- , dateSelectionHandler : Maybe (Calendar.Date -> msg)
    -- , singleDate : Maybe Calendar.Date
    -- , dateRangeStart : Maybe Calendar.Date
    -- , dateRangeEnd : Maybe Calendar.Date
    -- , dateRange : List Calendar.Date
    -- , singleDatePickerModel : SingleDatePicker.Model
    -- , doubleDatePickerModel : DoubleDatePicker.Model
    }

type Msg
    = NoOp
    -- | PreviousMonth
    -- | NextMonth
    -- | SelectDate Calendar.Date
    -- | UpdateDateRange Calendar.Date
    -- | SingleDatePickerMsg SingleDatePicker.Msg


type ExternalMsg
    = None


update : Model -> Msg -> ( Model, Cmd Msg, ExternalMsg )
update model msg =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            , None
            )

        -- PreviousMonth ->
        --     ( { model | primaryDate = Calendar.getPreviousMonth model.primaryDate }
        --     , Cmd.none
        --     , None
        --     )
        --
        -- NextMonth ->
        --     ( { model | primaryDate = Calendar.getNextMonth model.primaryDate }
        --     , Cmd.none
        --     , None
        --     )

        -- SelectDate date ->
        --     let
        --         _ = Debug.log "SelectDate called!" date
        --     in
        --     ( { model | singleDate = Just date }
        --     , Cmd.none
        --     , None
        --     )

        -- UpdateDateRange selectedDate ->
        --     case ( model.dateRangeStart, model.dateRangeEnd ) of
        --         ( Just start, Nothing ) ->
        --             ( { model
        --                 | dateRangeEnd = Just selectedDate
        --                 , dateRange = Calendar.getDateRange start selectedDate
        --               }
        --             , Cmd.none
        --             , None
        --             )
        --
        --         ( Just start, Just end ) ->
        --             ( { model
        --                 | dateRangeStart = Just selectedDate
        --                 , dateRangeEnd = Nothing
        --                 , dateRange = []
        --               }
        --             , Cmd.none
        --             , None
        --             )
        --
        --         ( Nothing, _ ) ->
        --             ( { model
        --                 | dateRangeStart = Just selectedDate
        --                 , dateRangeEnd = Nothing
        --                 , dateRange = []
        --               }
        --             , Cmd.none
        --             , None
        --             )
        -- SingleDatePickerMsg subMsg ->
        --     let
        --         (subModel, subCmd, extMsg) =
        --             SingleDatePicker.update model.singleDatePickerModel subMsg
        --     in
        --     ({ model
        --         | singleDatePickerModel = subModel
        --     }
        --     , Cmd.none
        --     , None
        --     )
        -- SetStartDate date ->
        --     ( model
        --     , Cmd.none
        --     , None
        --     )
        --
        -- SetEndDate date ->
        --     ( model
        --     , Cmd.none
        --     , None
        --     )
