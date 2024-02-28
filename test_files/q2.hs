tails :: [a] -> [[a]]
tails [] = [[]]
tails l = l ++ tails (tail l)

{-QC

prop :: [Int] -> Bool
prop xs = tails xs == correctTails xs

correctTails :: [a] -> [[a]]
correctTails [] = [[]]
correctTails l = l : correctTails (tail l)

QC-}