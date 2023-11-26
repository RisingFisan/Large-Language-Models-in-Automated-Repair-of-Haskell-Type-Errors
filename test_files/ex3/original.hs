mysum :: Num a => [a] -> a
mysum [] = 0
mysum (h:t) = h ++ mysum t