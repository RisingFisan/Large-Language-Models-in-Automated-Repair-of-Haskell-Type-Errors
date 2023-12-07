f :: Num a => [a] -> a
f [] = []
f (h:t) = h + f t