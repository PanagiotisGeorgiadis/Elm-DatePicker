# Changelog
All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [2.1.0] - 2019-07-25
### Added
- Added a helper function which **sets the selected date** on the `DatePicker` component.
- Added a helper function which **resets the selected date** on the `DatePicker` component.

## [2.0.0] - 2019-04-04
### Added
- Added a helper function which resets the visual selection of dates. This can be used by the
parent component and reset any visual selection in multiple different scenarios.
- Added a helper function which **sets the date range** in the `DateRangePicker's Model`. That
means that the consumer of the package will be able to **set a date range** without any user
interaction.

### Changed
- Changed the behavior of the **Single** `DatePicker` module. From now on the `TimePicker` module will
be visible from the start instead of spawning once the user has selected a date.
- Changed the logic surrounding the date selection flow in the `DateRangePicker` module. The logic is
changed for the scenario where the user has selected a date range and then they go on to select a new one.
Once they select the new **starting date** the `DateRangePicker` should fire a `DateRangeSelected Nothing`
external message.
- Changed the behavior of the **Double** `Date-Time Range Picker` module. From now on when the user selects
a **valid date range**, the **Calendar view** will change automatically to the **Clock view** so that they
can continue with their selection.
- Changed the behavior of the **Single** `Date-Time Range Picker` module in order to be consistent with the
**Single** `DatePicker` module.

### Fixed
- Fixed an issue on the primary date validation function which resulted in "focusing" on
the wrong date.
- Fixed a "wiring" issue on the `DateRangePicker` module that was caused by changing the behaviour
of the **Single** `Date-Time Range Picker`.

### Removed
- Removed unused dev dependencies from the **package.json** file.
- Removed the `disablePastDates` from the `NoLimit` constructor of the `DatePicker` module.
- Removed the `disablePastDates` from the `NoLimit` constructor of the `DateRangePicker` module.

## [1.0.0] - 2019-03-15
### Added
- Added the initial implementation and documentation of the `Elm-DatePicker` package.
