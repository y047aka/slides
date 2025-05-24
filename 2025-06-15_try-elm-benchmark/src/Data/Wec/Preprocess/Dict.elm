module Data.Wec.Preprocess.Dict exposing
    ( preprocess
    , startPositions_list, ordersByLap_dict, preprocess_
    , laps_
    )

{-|

@docs preprocess
@docs startPositions_list, ordersByLap_dict, preprocess_
@docs laps_

-}

import Data.Wec.Decoder as Wec
import Dict
import Dict.Extra
import List.Extra
import Motorsport.Car exposing (Car)
import Motorsport.Class as Class
import Motorsport.Lap exposing (Lap)


preprocess : List Wec.Lap -> List Car
preprocess laps =
    let
        startPositions =
            startPositions_list laps

        ordersByLap =
            ordersByLap_dict laps
    in
    laps
        |> Dict.Extra.groupBy .carNumber
        |> Dict.toList
        |> List.map
            (\( carNumber, laps__ ) ->
                preprocess_
                    { carNumber = carNumber
                    , laps = laps__
                    , startPositions = startPositions
                    , ordersByLap = ordersByLap
                    }
            )


startPositions_list : List Wec.Lap -> List String
startPositions_list laps =
    List.filter (\{ lapNumber } -> lapNumber == 1) laps
        |> List.sortBy .elapsed
        |> List.map .carNumber


type alias OrdersByLap =
    List { lapNumber : Int, order : List String }


ordersByLap_dict : List Wec.Lap -> OrdersByLap
ordersByLap_dict laps =
    laps
        |> Dict.Extra.groupBy .lapNumber
        |> Dict.toList
        |> List.map
            (\( lapNumber, cars ) ->
                { lapNumber = lapNumber
                , order = cars |> List.sortBy .elapsed |> List.map .carNumber
                }
            )


preprocess_ :
    { carNumber : String
    , laps : List Wec.Lap
    , startPositions : List String
    , ordersByLap : OrdersByLap
    }
    -> Car
preprocess_ { carNumber, laps, startPositions, ordersByLap } =
    let
        { currentDriver_, class_, group_, team_, manufacturer_ } =
            List.head laps
                |> Maybe.map
                    (\{ driverName, class, group, team, manufacturer } ->
                        { currentDriver_ = driverName
                        , class_ = class
                        , group_ = group
                        , team_ = team
                        , manufacturer_ = manufacturer
                        }
                    )
                |> Maybe.withDefault
                    { class_ = Class.none
                    , team_ = ""
                    , group_ = ""
                    , currentDriver_ = ""
                    , manufacturer_ = ""
                    }

        drivers =
            List.Extra.uniqueBy .driverName laps
                |> List.map
                    (\{ driverName } ->
                        { name = driverName
                        , isCurrentDriver = driverName == currentDriver_
                        }
                    )

        startPosition =
            startPositions
                |> List.Extra.findIndex ((==) carNumber)
                |> Maybe.withDefault 0
    in
    { carNumber = carNumber
    , drivers = drivers
    , class = class_
    , group = group_
    , team = team_
    , manufacturer = manufacturer_
    , startPosition = startPosition
    , laps =
        laps_
            { carNumber = carNumber
            , laps = laps
            , ordersByLap = ordersByLap
            }
    , currentLap = Nothing
    , lastLap = Nothing
    }


laps_ :
    { carNumber : String
    , laps : List Wec.Lap
    , ordersByLap : OrdersByLap
    }
    -> List Lap
laps_ { carNumber, laps, ordersByLap } =
    laps
        |> List.indexedMap
            (\index { driverName, lapNumber, lapTime, s1, s2, s3, elapsed } ->
                { carNumber = carNumber
                , driver = driverName
                , lap = lapNumber
                , position =
                    getPositionAt { carNumber = carNumber, lapNumber = lapNumber } ordersByLap
                , time = lapTime
                , best =
                    laps
                        |> List.take (index + 1)
                        |> List.map .lapTime
                        |> List.minimum
                        |> Maybe.withDefault 0
                , sector_1 = Maybe.withDefault 0 s1
                , sector_2 = Maybe.withDefault 0 s2
                , sector_3 = Maybe.withDefault 0 s3
                , s1_best =
                    laps
                        |> List.take (index + 1)
                        |> List.filterMap .s1
                        |> List.minimum
                        |> Maybe.withDefault 0
                , s2_best =
                    laps
                        |> List.take (index + 1)
                        |> List.filterMap .s2
                        |> List.minimum
                        |> Maybe.withDefault 0
                , s3_best =
                    laps
                        |> List.take (index + 1)
                        |> List.filterMap .s3
                        |> List.minimum
                        |> Maybe.withDefault 0
                , elapsed = elapsed
                }
            )


getPositionAt : { carNumber : String, lapNumber : Int } -> OrdersByLap -> Maybe Int
getPositionAt { carNumber, lapNumber } ordersByLap =
    ordersByLap
        |> List.Extra.find (.lapNumber >> (==) lapNumber)
        |> Maybe.andThen (.order >> List.Extra.findIndex ((==) carNumber))
