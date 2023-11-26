import Test.QuickCheck

-- [INSERT]

prop_tails :: [Int] -> Bool
prop_tails xs = tails xs == correctTails xs

correctTails :: [a] -> [[a]]
correctTails [] = [[]]
correctTails l = l : correctTails (tail l)

main :: IO ()
main = quickCheck prop_tails