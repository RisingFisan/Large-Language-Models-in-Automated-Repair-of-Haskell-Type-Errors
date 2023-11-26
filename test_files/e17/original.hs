func :: [[Int]] -> [Int]
func [] = []
func ((u:us):y) | u + us > 10 = (u : us) ++ [] ++ func y
                | otherwise = func y