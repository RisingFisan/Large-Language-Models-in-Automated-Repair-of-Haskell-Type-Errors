import Prelude hiding (zip)

f :: [a] -> [b] -> [(a,b)]
f _ [] = []
f [] _ = []
f (h:t) (x:y) = (h,x) ++ f t y