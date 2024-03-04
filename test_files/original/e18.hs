func :: [[Int]] -> [Int]
func [] = []
func ((h:s):t) | sum (h:s) > 10 = [h : s] ++ func t
               | otherwise = func t

{-QC

funcCorrect :: [[Int]] -> [Int]
funcCorrect l = concat (filter (\x -> sum x > 10) l)

prop :: [[Int]] -> Property
prop xs = not (any null xs) ==> func xs == funcCorrect xs

QC-}