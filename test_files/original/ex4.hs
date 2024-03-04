emptyList :: [a] -> Bool
emptyList xs = not xs

{-QC

prop :: [Int] -> Bool
prop xs = emptyList xs == null xs

QC-}