module DatePicker.Internal.I18n exposing (..)

import DatePicker.I18n exposing (I18n, TextMode(..))
import Time exposing (Month(..), Weekday(..))


defaultI18n : I18n
defaultI18n =
    { monthToString = monthToString
    , weekdayToString = weekdayToString
    , todayButtonText = "Today"
    }


monthToString : TextMode -> Month -> String
monthToString mode month =
    let
        monthString =
            case month of
                Jan ->
                    "January"

                Feb ->
                    "February"

                Mar ->
                    "March"

                Apr ->
                    "April"

                May ->
                    "May"

                Jun ->
                    "June"

                Jul ->
                    "July"

                Aug ->
                    "August"

                Sep ->
                    "September"

                Oct ->
                    "October"

                Nov ->
                    "November"

                Dec ->
                    "December"
    in
    case mode of
        Condensed ->
            String.left 3 monthString

        Full ->
            monthString


weekdayToString : TextMode -> Weekday -> String
weekdayToString mode weekday =
    let
        weekdayString =
            case weekday of
                Mon ->
                    "Monday"

                Tue ->
                    "Tuesday"

                Wed ->
                    "Wednesday"

                Thu ->
                    "Thursday"

                Fri ->
                    "Friday"

                Sat ->
                    "Saturday"

                Sun ->
                    "Sunday"
    in
    case mode of
        Condensed ->
            String.left 3 weekdayString

        Full ->
            weekdayString
