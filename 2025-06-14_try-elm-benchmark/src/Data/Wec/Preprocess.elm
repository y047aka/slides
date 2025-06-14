module Data.Wec.Preprocess exposing
    ( preprocess
    , preprocessHelper
    , laps_
    )

{-|

@docs preprocess
@docs preprocessHelper
@docs laps_

-}

import AssocList
import AssocList.Extra
import Data.Wec.Decoder as Wec
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
            ordersByLap_list laps
    in
    laps
        |> AssocList.Extra.groupBy .carNumber
        |> AssocList.toList
        |> List.map
            (\( carNumber, laps__ ) ->
                preprocessHelper
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


ordersByLap_list : List Wec.Lap -> OrdersByLap
ordersByLap_list laps =
    laps
        |> AssocList.Extra.groupBy .lapNumber
        |> AssocList.toList
        |> List.map
            (\( lapNumber, cars ) ->
                { lapNumber = lapNumber
                , order = cars |> List.sortBy .elapsed |> List.map .carNumber
                }
            )


preprocessHelper :
    { carNumber : String
    , laps : List Wec.Lap
    , startPositions : List String
    , ordersByLap : OrdersByLap
    }
    -> Car
preprocessHelper { carNumber, laps, startPositions, ordersByLap } =
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


type alias Acc =
    { bestLapTime : Maybe Int
    , bestS1 : Maybe Int
    , bestS2 : Maybe Int
    , bestS3 : Maybe Int
    , laps : List Lap
    }


laps_ :
    { carNumber : String
    , laps : List Wec.Lap
    , ordersByLap : OrdersByLap
    }
    -> List Lap
laps_ { carNumber, laps, ordersByLap } =
    let
        step : Wec.Lap -> Acc -> Acc
        step { driverName, lapNumber, lapTime, s1, s2, s3, elapsed } acc =
            let
                bestLapTime =
                    List.minimum (lapTime :: List.filterMap identity [ acc.bestLapTime ])

                ( bestS1, bestS2, bestS3 ) =
                    ( List.minimum (List.filterMap identity [ s1, acc.bestS1 ])
                    , List.minimum (List.filterMap identity [ s2, acc.bestS2 ])
                    , List.minimum (List.filterMap identity [ s3, acc.bestS3 ])
                    )

                currentLap =
                    { carNumber = carNumber
                    , driver = driverName
                    , lap = lapNumber
                    , position = getPositionAt { carNumber = carNumber, lapNumber = lapNumber } ordersByLap
                    , time = lapTime
                    , best = Maybe.withDefault 0 bestLapTime
                    , sector_1 = Maybe.withDefault 0 s1
                    , sector_2 = Maybe.withDefault 0 s2
                    , sector_3 = Maybe.withDefault 0 s3
                    , s1_best = Maybe.withDefault 0 bestS1
                    , s2_best = Maybe.withDefault 0 bestS2
                    , s3_best = Maybe.withDefault 0 bestS3
                    , elapsed = elapsed
                    }
            in
            { bestLapTime = bestLapTime
            , bestS1 = bestS1
            , bestS2 = bestS2
            , bestS3 = bestS3
            , laps = currentLap :: acc.laps
            }

        initialAcc =
            { bestLapTime = Nothing
            , bestS1 = Nothing
            , bestS2 = Nothing
            , bestS3 = Nothing
            , laps = []
            }
    in
    laps
        |> List.foldl step initialAcc
        |> .laps
        |> List.reverse


getPositionAt : { carNumber : String, lapNumber : Int } -> OrdersByLap -> Maybe Int
getPositionAt { carNumber, lapNumber } ordersByLap =
    ordersByLap
        |> List.Extra.find (.lapNumber >> (==) lapNumber)
        |> Maybe.andThen (.order >> List.Extra.findIndex ((==) carNumber))
