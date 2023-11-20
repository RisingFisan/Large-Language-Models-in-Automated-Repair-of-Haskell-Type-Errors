mysum :: Num a => [a] -> a
mysum [] = []
mysum (h:t) = h + mysum t