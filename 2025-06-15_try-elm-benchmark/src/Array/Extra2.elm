module Array.Extra2 exposing (sortBy)

import Array exposing (Array)


{-| Sort values by a derived property.

    alice = { name="Alice", height=1.62 }
    bob   = { name="Bob"  , height=1.85 }
    chuck = { name="Chuck", height=1.76 }

    sortBy .name   [chuck,alice,bob] == [alice,bob,chuck]
    sortBy .height [chuck,alice,bob] == [alice,chuck,bob]

    sortBy String.length ["mouse","cat"] == ["cat","mouse"]

-}
sortBy : (a -> comparable) -> Array a -> Array a
sortBy toComparable array =
    let
        len =
            Array.length array
    in
    if len <= 1 then
        array

    else
        mergeSort toComparable array


{-| Pure Array-based merge sort implementation
-}
mergeSort : (a -> comparable) -> Array a -> Array a
mergeSort toComparable array =
    let
        len =
            Array.length array
    in
    if len <= 1 then
        array

    else
        let
            mid =
                len // 2

            left =
                Array.slice 0 mid array

            right =
                Array.slice mid len array

            sortedLeft =
                mergeSort toComparable left

            sortedRight =
                mergeSort toComparable right
        in
        merge toComparable sortedLeft sortedRight


{-| Merge two sorted arrays into one sorted array
-}
merge : (a -> comparable) -> Array a -> Array a -> Array a
merge toComparable left right =
    let
        leftLen =
            Array.length left

        rightLen =
            Array.length right
    in
    mergeHelper toComparable left right Array.empty 0 0 leftLen rightLen


{-| Helper function for merging arrays
-}
mergeHelper : (a -> comparable) -> Array a -> Array a -> Array a -> Int -> Int -> Int -> Int -> Array a
mergeHelper toComparable left right result leftIndex rightIndex leftLen rightLen =
    if leftIndex >= leftLen then
        -- All left elements used, append remaining right elements
        Array.append result (Array.slice rightIndex rightLen right)

    else if rightIndex >= rightLen then
        -- All right elements used, append remaining left elements
        Array.append result (Array.slice leftIndex leftLen left)

    else
        -- Compare current elements and take the smaller one
        case ( Array.get leftIndex left, Array.get rightIndex right ) of
            ( Just leftVal, Just rightVal ) ->
                if compare (toComparable leftVal) (toComparable rightVal) /= GT then
                    -- Left value is smaller or equal, take it
                    mergeHelper toComparable left right (Array.push leftVal result) (leftIndex + 1) rightIndex leftLen rightLen

                else
                    -- Right value is smaller, take it
                    mergeHelper toComparable left right (Array.push rightVal result) leftIndex (rightIndex + 1) leftLen rightLen

            _ ->
                -- This should never happen with valid indices
                result
