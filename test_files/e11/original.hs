type MSet a = [(a,Int)]

removeMSet :: Eq a => a -> MSet a -> MSet a
removeMSet _ [] = []
removeMSet m ((a,b):xs) = if m == a
                          then if b == 1
                               then [xs]
                               else (a,b-1):xs
                          else (a,b):removeMSet m xs