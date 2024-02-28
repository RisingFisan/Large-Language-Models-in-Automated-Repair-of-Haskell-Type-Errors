func :: [[Int]] -> [Int]
func [] = []
func (h:t) = if sum h > 10 then h : func t else func t

{-QC

funcCorrect :: [[Int]] -> [Int]
funcCorrect l = concat (filter (\x -> sum x > 10) l)

prop :: [[Int]] -> Bool
prop xs = func xs == funcCorrect xs

QC-}