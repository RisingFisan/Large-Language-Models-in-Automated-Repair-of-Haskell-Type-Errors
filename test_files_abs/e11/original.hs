type MSet a = [(a,Int)]

f :: Eq a => a -> MSet a -> MSet a
f _ [] = []
f m ((a,b):xs) = if m == a
                          then if b == 1
                               then [xs]
                               else (a,b-1):xs
                          else (a,b):f m xs