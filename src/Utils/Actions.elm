module Utils.Actions exposing (fireAction)

import Task


fireAction : msg -> Cmd msg
fireAction msg =
    Task.perform (\_ -> msg) (Task.succeed ())
