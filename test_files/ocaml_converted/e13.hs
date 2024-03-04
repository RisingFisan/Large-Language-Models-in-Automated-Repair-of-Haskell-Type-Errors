
keep [] = []
keep (fst : rest) = fst + rest

-- [TEST CASE]

keep [3,4] = [3,4]

{-QC

kkeep [] = []
kkeep (fst : rest) = fst : rest

prop :: [Int] -> Bool
prop x = keep x == kkeep x

QC-}