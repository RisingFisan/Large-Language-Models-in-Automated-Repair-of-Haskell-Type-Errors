f :: [[Int]] -> [Int]
f [] = []
f (h:t) = if sum h > 10 then [h] ++ f t else f t