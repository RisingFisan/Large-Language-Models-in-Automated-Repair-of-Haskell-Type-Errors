myreverse :: [a] -> [a]
myreverse [] = []
myreverse (h:t) = myreverse t ++ h