type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((x,y):z) | y > 0 = x : f [(x,y-1):z]
            | otherwise = f z