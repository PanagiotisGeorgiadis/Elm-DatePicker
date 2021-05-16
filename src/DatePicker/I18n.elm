module DatePicker.I18n exposing (I18n, TextMode(..))

{-| The `I18n` module is responsible for providing a config for translating parts of the
`DatePicker` or `DateRangePicker` components. When initializing a `DatePicker` you can provide an `I18n` config
which will in turn be used to translate anything that has been configured.

If `Nothing` is provided as the `I18n` config, the language will be defaulted to `English` with the
default text that can be seen in the [example screenshots](https://github.com/PanagiotisGeorgiadis/Elm-DatePicker/tree/master/screenshots).

@docs I18n, TextMode

-}

import Time exposing (Month, Weekday)


{-| The `I18n` model.
-}
type alias I18n =
    { monthToString : TextMode -> Month -> String
    , weekdayToString : TextMode -> Weekday -> String
    , todayButtonText : String
    }


{-| The Month / Weekday Text Mode
-}
type TextMode
    = Condensed
    | Full
