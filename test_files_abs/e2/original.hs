type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((a,0):t) = f t
f ((a,b):t) = a ++ f ((a,b-1):t)