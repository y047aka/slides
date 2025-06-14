module Data.Wec.Decoder exposing (Lap, lapDecoder)

import Csv.Decode as Decode exposing (Decoder, field, float, int, pipeline, string)
import Motorsport.Class as Class exposing (Class)
import Motorsport.Duration as Duration exposing (Duration)



-- MODEL


type alias Lap =
    { carNumber : String
    , driverNumber : Int
    , lapNumber : Int
    , lapTime : RaceClock
    , lapImprovement : Int
    , crossingFinishLineInPit : String
    , s1 : Maybe RaceClock -- 2023年のデータで部分的に欠落しているのでMaybeを付けている
    , s1Improvement : Int
    , s2 : Maybe RaceClock -- 2023年のデータで部分的に欠落しているのでMaybeを付けている
    , s2Improvement : Int
    , s3 : Maybe RaceClock -- 2024年のデータで部分的に欠落しているのでMaybeを付けている
    , s3Improvement : Int
    , kph : Float
    , elapsed : RaceClock
    , hour : RaceClock
    , topSpeed : Maybe Float -- 2023年のデータで部分的に欠落しているのでMaybeを付けている
    , driverName : String
    , pitTime : Maybe RaceClock
    , class : Class
    , group : String
    , team : String
    , manufacturer : String
    }


type alias RaceClock =
    Duration



-- DECODER


lapDecoder : Decoder Lap
lapDecoder =
    Decode.into Lap
        |> pipeline (field "NUMBER" string)
        |> pipeline (field "DRIVER_NUMBER" int)
        |> pipeline (field "LAP_NUMBER" int)
        |> pipeline (field "LAP_TIME" raceClockDecoder)
        |> pipeline (field "LAP_IMPROVEMENT" int)
        |> pipeline (field "CROSSING_FINISH_LINE_IN_PIT" string)
        |> pipeline (field "S1" <| Decode.blank raceClockDecoder)
        |> pipeline (field "S1_IMPROVEMENT" int)
        |> pipeline (field "S2" <| Decode.blank raceClockDecoder)
        |> pipeline (field "S2_IMPROVEMENT" int)
        |> pipeline (field "S3" <| Decode.blank raceClockDecoder)
        |> pipeline (field "S3_IMPROVEMENT" int)
        |> pipeline (field "KPH" float)
        |> pipeline (field "ELAPSED" raceClockDecoder)
        |> pipeline (field "HOUR" raceClockDecoder)
        |> pipeline (field "TOP_SPEED" <| Decode.blank Decode.float)
        |> pipeline (field "DRIVER_NAME" string)
        |> pipeline (field "PIT_TIME" <| Decode.blank raceClockDecoder)
        |> pipeline (field "CLASS" classDecoder)
        |> pipeline (field "GROUP" string)
        |> pipeline (field "TEAM" string)
        |> pipeline (field "MANUFACTURER" string)


raceClockDecoder : Decoder RaceClock
raceClockDecoder =
    string |> Decode.andThen (Duration.fromString >> Decode.fromMaybe "Expected a RaceClock")


classDecoder : Decoder Class
classDecoder =
    string |> Decode.andThen (Class.fromString >> Decode.fromMaybe "Expected a Class")
