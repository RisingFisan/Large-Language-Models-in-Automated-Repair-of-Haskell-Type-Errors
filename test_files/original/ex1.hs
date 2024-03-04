myreverse :: [a] -> [a]
myreverse [] = []
myreverse (h:t) = myreverse t ++ h

{-QC

prop :: [Int] -> Bool
prop xs = myreverse xs == reverse xs

QC-}