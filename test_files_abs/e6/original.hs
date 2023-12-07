type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((x,n):t)
    | n == 0 = f t
    | otherwise = x ++ f ((x,n-1):t)