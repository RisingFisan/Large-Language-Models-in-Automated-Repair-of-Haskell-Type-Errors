f :: [[Int]] -> [Int]
f [] = []
f ((u:us):y) | u + us > 10 = (u : us) ++ [] ++ f y
                | otherwise = f y