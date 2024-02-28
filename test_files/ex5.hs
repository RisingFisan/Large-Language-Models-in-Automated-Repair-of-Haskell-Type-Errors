addOne :: Int -> Int
addOne x = x + '1'

{-QC

prop :: Int -> Bool
prop x = addOne x == x + 1

QC-}