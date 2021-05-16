module DateRangePicker.Types exposing
    ( ViewType(..)
    , CalendarConfig, DateLimit(..)
    , TimePickerConfig
    , I18n
    )

{-| Contains types that are being used by the _**parent application**_ in order to initialise
a `DateRangePicker`.


# Types

@docs ViewType

@docs CalendarConfig, DateLimit

@docs TimePickerConfig

@docs I18n

-}

import Clock
import DateTime exposing (DateTime)
import TimePicker.Types as TimePicker


{-| The Calendar ViewTypes.
-}
type ViewType
    = Single
    | Double


{-| Used in order to configure the `Calendar` part of the `DateRangePicker`.

  - **`today`:** Represents today as `DateTime` provided by the **parent application**.

  - **`primaryDate`:** Represents the default `month - year` calendar screen.
      - If the **primaryDate** is set to `Nothing` the `DateRangePicker` will
        set the **primaryDate** equal to the **today** property.
      - If the consumer has provided both a **primaryDate** and a **dateLimit**
        but the **primaryDate** is out of bounds, the `DateRangePicker` will set
        the **primaryDate** equal to the minium date of the constrains.

  - **`dateLimit`:** Used to impose date restrictions on the `DateRangePicker`.
    The different configuration settings can be seen on the
    [DateLimit](DateRangePicker.Types#DateLimit) definition.

  - **`dateRangeOffset`:** Used to set a minimum length on the selected date range.
    This basically means that if we set a **minimumDateRangeLength** of 3, the user
    will be able to select a minimum of 3 dates.

-}
type alias CalendarConfig =
    { today : DateTime
    , primaryDate : Maybe DateTime
    , dateLimit : DateLimit
    , dateRangeOffset : Maybe { minDateRangeLength : Int }
    }


{-| The _**optional**_ `DateRangePicker` date restrictions. You can cover most of the
date restriction cases with the type below. If by any change you need to achieve
a case which is not possible by the current implementation please raise an issue
on the repository of this package.

    -- A Custom imposed restriction for the year 2019
    -- inclusive of the minDate and maxDate.
    DateLimit { minDate = 1 Jan 2019, maxDate = 31 Dec 2019 }

    -- An unlimited Calendar.
    NoLimit

-}
type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit


{-| The TimePicker `I18n` config

  - **start:** Refers to the start time title
  - **end:** Refers to the end time title
  - **checkboxText:** Refers to the `mirrorTimes` checkbox text

-}
type alias I18n =
    { start : String
    , end : String
    , checkboxText : String
    }


{-| Used in order to configure the `TimePicker` part of the `DateRangePicker`.

  - **`pickerType`:** Defines the type of the picker as described in the [TimePicker module](TimePicker.Types#PickerType).

  - **`defaultTime`:** Defines the defaultTime that will be used as the default value of the `TimePicker`.

  - **`mirrorTimes`:** Dictates if both the `TimePickers` should be in sync.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    **Note:** The synchronisation takes place using the
    [onBlur](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onBlur)
    event of the input.

  - **i18n:** The TimePicker `I18n` config

-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , mirrorTimes : Bool
    , i18n : I18n
    }
