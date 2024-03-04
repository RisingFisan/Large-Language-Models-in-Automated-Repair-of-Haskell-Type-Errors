func :: [[Int]] -> [Int]
func [] = []
func ((u:us):y) | u + us > 10 = (u : us) ++ [] ++ func y
                | otherwise = func y

{-QC

funcCorrect :: [[Int]] -> [Int]
funcCorrect l = concat (filter (\x -> sum x > 10) l)

prop :: [[Int]] -> Bool
prop xs = func xs == funcCorrect xs


QC-}