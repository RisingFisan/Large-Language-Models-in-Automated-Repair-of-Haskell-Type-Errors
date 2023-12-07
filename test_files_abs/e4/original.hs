type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((h,hs):t) | hs == 0 = f t
             | otherwise = 'h' ++ f ((h,hs-1):t)