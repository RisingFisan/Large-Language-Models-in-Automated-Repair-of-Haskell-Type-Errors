type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((h,t):y) = t * h ++ f y