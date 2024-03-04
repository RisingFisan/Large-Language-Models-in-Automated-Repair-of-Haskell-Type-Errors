f :: [Int] -> Int
f [] = []
f (fst:rest) = fst + 1

{-QC

g :: [Int] -> Int
g [] = 0
g (fst:rest) = fst + 1

prop :: [Int] -> Bool
prop x = f x == g x

QC-}