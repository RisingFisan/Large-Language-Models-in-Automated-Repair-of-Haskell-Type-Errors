f :: Num a => [a] -> a
f [] = 0
f (h:t) = h ++ f t