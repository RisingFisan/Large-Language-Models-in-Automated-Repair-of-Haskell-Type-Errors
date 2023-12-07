type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((a,b):t) = replicate b 'a' ++ f t