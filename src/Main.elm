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
import Components.DoubleDatePicker.Update as DoubleDatePicker
import Components.DoubleDatePicker.View as DoubleDatePicker
import Components.SingleDatePicker.Update as SingleDatePicker
import Components.SingleDatePicker.View as SingleDatePicker
import DateTime.Calendar as Calendar
import DateTime.DateTime as DateTime
import Html exposing (..)
import Task
import Time
import Url exposing (Url)
import Utils.Time as Time


type alias Flags =
    ()


type alias Model =
    { today : Maybe Time.Posix

    -- , todayCalendar : DateTime.DateTime
    , singleDatePickerModel : Maybe SingleDatePicker.Model
    , doubleDatePickerModel : Maybe DoubleDatePicker.Model
    }


type Msg
    = NoOp
    | Initialise Time.Posix
      -- | DatePickerMsg DatePicker.Msg
    | SingleDatePickerMsg SingleDatePicker.Msg
    | DoubleDatePickerMsg DoubleDatePicker.Msg



-- | SingleDatePickerMsg SingleDatePicker.Msg
-- | DoubleDatePickerMsg DatePicker.Msg
{-
   Configs to add:
   allowPastDateSelection
   showOnHover selection
   -- Maybe if you dont showOnHover selection we disable past dates and
   -- select only future dates.
   useKeyboardListeners ( Only on single date picker ? )

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
                -- _ =
                --     Debug.log "Today In Posix" today
                -- todayDateTime =
                --     DateTime.fromPosix Time.utc todayPosix
                --
                -- todayDate =
                --     DateTime.date todayDateTime
                _ =
                    0

                todayDateTime =
                    DateTime.fromPosix todayPosix
            in
            ( { model
                | today = Just todayPosix
                , singleDatePickerModel = Just (SingleDatePicker.initialise todayDateTime)
                , doubleDatePickerModel = Just (DoubleDatePicker.initialise todayDateTime)
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


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { today = Nothing
      , singleDatePickerModel = Nothing
      , doubleDatePickerModel = Nothing
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
