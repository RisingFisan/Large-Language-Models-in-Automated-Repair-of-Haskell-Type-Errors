mysum :: Num a => [a] -> a
mysum [] = []
mysum (h:t) = h + mysum t

{-QC

prop :: [Int] -> Bool
prop xs = mysum xs == sum xs

QC-}