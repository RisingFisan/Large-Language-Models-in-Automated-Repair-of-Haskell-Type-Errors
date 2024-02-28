mysum :: Num a => [a] -> a
mysum [] = 0
mysum (h:t) = h ++ mysum t

{-QC

prop :: [Int] -> Bool
prop xs = mysum xs == sum xs

QC-}