module Utils.Maybe exposing (mapWithDefault)


mapWithDefault : (a -> b) -> b -> Maybe a -> b
mapWithDefault fn default =
    Maybe.withDefault default << Maybe.map fn
