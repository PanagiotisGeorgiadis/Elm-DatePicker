# Elm-DatePicker

![Latest version of the package][PackageVersion]
![Latest Elm version supported][ElmVersion]
![Status of direct dependencies][DependenciesStatus]
![License of the package][PackageLicense]

A `DateTime` picker component built using Elm 0.19. `Elm-DatePicker` is a reusable **date-time picker**
component that's focused on providing functionality and ease of use.

## Dependencies

This package depends on the [elm/time][elm-time-url] and [elm-datetime][elm-datetime-url] packages.
That basically means that all the date related functionality as well as
the **resulting dates** that will be returned by the `DatePicker` component
will be of [DateTime][datetime-type-url] type which is implemented in the
[elm-datetime][elm-datetime-url] package.

## Install

```
elm install PanagiotisGeorgiadis/elm-datepicker
```

## Usage

For usage examples you can check out the following links:

### DatePicker

  - [Single Date picker example][single-date-picker-example]
  - [Double Date picker example][double-date-picker-example]

  - [Single DateTime picker example][single-datetime-picker-example]
  - [Double DateTime picker example][double-datetime-picker-example]

### DateRangePicker

  - [Single Date range picker example][single-date-range-picker-example]
  - [Double Date range picker example][double-date-range-picker-example]

  - [Single DateTime range picker example][single-datetime-range-picker-example]
  - [Double DateTime range picker example][double-datetime-range-picker-example]


**Note:** In all of the examples the returned result from the `DatePicker` package
will always be of `DateTime` type. **If there is no `TimePickerConfig` defined, the
time part of the selected `DateTime` will be set to midnight hours (00:00:00.000).**


## Styling

You can get the styles from [this demo app](https://github.com/PanagiotisGeorgiadis/ElmDatePicker)
or you can clone the repo and modify the styles as you wish.


[elm-time-url]: https://package.elm-lang.org/packages/elm/time/latest/
[elm-datetime-url]: https://package.elm-lang.org/packages/PanagiotisGeorgiadis/elm-datetime/latest/
[datetime-type-url]: https://package.elm-lang.org/packages/PanagiotisGeorgiadis/elm-datetime/latest/DateTime#DateTime

[single-date-picker-example]: https://ellie-app.com/new
[double-date-picker-example]: https://ellie-app.com/new

[single-datetime-picker-example]: https://ellie-app.com/new
[double-datetime-picker-example]: https://ellie-app.com/new

[single-date-range-picker-example]: https://ellie-app.com/new
[double-date-range-picker-example]: https://ellie-app.com/new

[single-datetime-range-picker-example]: https://ellie-app.com/new
[double-datetime-range-picker-example]: https://ellie-app.com/new

[PackageVersion]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datepicker/version.svg
[ElmVersion]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datepicker/elm-version.svg
[DependenciesStatus]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datepicker/dependencies.svg
[PackageLicense]: https://reiner-dolp.github.io/elm-badges/PanagiotisGeorgiadis/elm-datepicker/license.svg
