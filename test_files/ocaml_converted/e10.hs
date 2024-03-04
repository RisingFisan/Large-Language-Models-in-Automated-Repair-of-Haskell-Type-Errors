f :: [Int] -> [Int]
f [] = []
f (fst:rest) = (fst ** fst) : (f rest)

f [3,8] = [6,16]

{-QC

g :: [Int] -> [Int]
g [] = []
g (fst:rest) = (fst + fst) : (g rest)

prop :: [Int] -> Bool
prop x = f x == g x

QC-}