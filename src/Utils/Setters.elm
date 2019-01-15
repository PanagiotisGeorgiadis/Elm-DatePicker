module Utils.Setters exposing (updateDisablePastDates)


updateDisablePastDates : Bool -> { a | disablePastDates : Bool } -> { a | disablePastDates : Bool }
updateDisablePastDates val model =
    { model | disablePastDates = val }
