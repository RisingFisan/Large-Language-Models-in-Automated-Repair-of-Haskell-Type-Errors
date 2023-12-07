f :: [[Int]] -> [Int]
f [] = []
f ((h:s):t) | sum (h:s) <= 10 = [h : s] ++ f t
            | otherwise = f t