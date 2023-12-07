type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((a,i):xs) = if i == 0 then f xs
               else 'a' : f ((a,i-1):xs)