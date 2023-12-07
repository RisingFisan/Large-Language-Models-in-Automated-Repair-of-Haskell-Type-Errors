f :: [a] -> [a]
f [] = []
f (h:t) = f t ++ h