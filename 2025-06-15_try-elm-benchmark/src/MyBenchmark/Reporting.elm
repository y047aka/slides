module MyBenchmark.Reporting exposing (Report(..), fromBenchmark)

{-| Reporting for Benchmarks

@docs Report, fromBenchmark

-}

import MyBenchmark.Benchmark as Benchmark exposing (Benchmark)
import MyBenchmark.Status exposing (Status(..))


{-| Reports are the public version of Benchmarks.

Each tag of Report has a name and some other information about the
structure of a benchmarking run.

-}
type Report
    = Single String Status
    | Series String (List ( String, Status ))
    | Group String (List Report)



-- Interop


{-| Get a report from a Benchmark.
-}
fromBenchmark : Benchmark -> Report
fromBenchmark internal =
    case internal of
        Benchmark.Single name _ status ->
            Single name status

        Benchmark.Series name benchmarks ->
            benchmarks
                |> List.map (\( childName, _, status ) -> ( childName, status ))
                |> Series name

        Benchmark.Group name benchmarks ->
            Group name (List.map fromBenchmark benchmarks)
