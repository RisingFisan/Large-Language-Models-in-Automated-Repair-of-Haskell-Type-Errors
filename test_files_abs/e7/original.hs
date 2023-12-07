type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((h1,h2):t) = replicate h2 h1 : f t