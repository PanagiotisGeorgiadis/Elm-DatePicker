module DatePicker.Types exposing
    ( ViewType(..)
    , CalendarConfig, DateLimit(..)
    , TimePickerConfig
    )

{-| Contains types that are being used by the _**parent application**_ in order to initialise
a `DatePicker`.


# Types

@docs ViewType

@docs CalendarConfig, DateLimit

@docs TimePickerConfig

-}

import Clock
import DateTime exposing (DateTime)
import TimePicker.Types as TimePicker


{-| The Calendar ViewType.

**Single date picker.**

![Single date picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Single-Date-Picker.png "Single date picker")

**Single date-time picker.**

![Single date-time picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Single-DateTime-Picker.png "Single date-time picker")

**Double date picker.**

![Double date picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-Date-Picker.png "Double date picker.")

**Double date picker.**

![Double date-time picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-DateTime-Picker.png "Double date-time picker")

-}
type ViewType
    = Single
    | Double


{-| Used in order to configure the `Calendar` part of the `DatePicker`.

  - **`today`:** Represents today as `DateTime` provided by the **parent application**.

  - **`primaryDate`:** Represents the default `month - year` calendar screen.
      - If the **primaryDate** is set to `Nothing` the `DatePicker` will
        set the **primaryDate** equal to the **today** property.

      - If the consumer has provided both a **primaryDate** and a **dateLimit**
        but the **primaryDate** is out of bounds, the `DatePicker` will set
        the **primaryDate** equal to the minium date of the constrains.

  - **`dateLimit`:** Used to impose date restrictions on the `DatePicker`.
    The different configuration settings can be seen on the
    [DateLimit](DatePicker.Types#DateLimit) definition.

-}
type alias CalendarConfig =
    { today : DateTime
    , primaryDate : Maybe DateTime
    , dateLimit : DateLimit
    }


{-| The _**optional**_ `DatePicker` date restrictions. You can cover most of the
date restriction cases with the type below. If by any change you need to achieve
a case which is not possible by the current implementation please raise an issue
on the repository of the package.

    -- A Custom imposed restriction for the year 2019
    -- inclusive of the minDate and maxDate.
    DateLimit { minDate = 1 Jan 2019, maxDate = 31 Dec 2019 }

    -- An unlimited Calendar.
    NoLimit { disablePastDates = False }

    -- Allows only `future date selection`.
    NoLimit { disablePastDates = True }

-}
type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }


{-| Used in order to configure the `TimePicker` part of the `DatePicker`.

  - **`pickerType`:** Defines the type of the picker as described in the [TimePicker module](TimePicker.Types#PickerType).

  - **`defaultTime`:** Defines the defaultTime that will be used as the default value of the `TimePicker`.

  - **`pickerTitle`:** Defines the `TimePicker` title.

-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , pickerTitle : String
    }
