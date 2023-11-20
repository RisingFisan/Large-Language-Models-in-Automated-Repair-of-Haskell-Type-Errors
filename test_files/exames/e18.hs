func :: [[Int]] -> [Int]
func [] = []
func ((h:s):t) | sum (h:s) <= 10 = [h : s] ++ func t
               | otherwise = func t