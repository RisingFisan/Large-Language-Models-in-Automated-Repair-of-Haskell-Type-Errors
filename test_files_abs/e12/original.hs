type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((a,n):t) = show (replicate n a ++ f t)