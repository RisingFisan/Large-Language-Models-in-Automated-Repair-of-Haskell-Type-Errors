type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((a,b):t) 
    | b == 1 = a : f [t]
    | otherwise = a : f ((a,b-1):t)