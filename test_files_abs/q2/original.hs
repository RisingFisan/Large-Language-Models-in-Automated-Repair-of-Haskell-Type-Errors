f :: [a] -> [[a]]
f [] = [[]]
f l = l ++ f (tail l)