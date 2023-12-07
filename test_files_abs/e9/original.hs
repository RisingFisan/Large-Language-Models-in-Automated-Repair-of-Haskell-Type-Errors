type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((x,y):t)
    | y == 0 = f t
    | otherwise = "x" ++ f ((x,y-1):t)