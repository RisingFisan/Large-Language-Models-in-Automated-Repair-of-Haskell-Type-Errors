pares :: [Int] -> [Int]
pares l = [[x] | x <- l, even x]

{-QC

prop :: [Int] -> Bool
prop xs = pares xs == filter even xs

QC-}