import Prelude hiding (zip)

zip :: [a] -> [b] -> [(a,b)]
zip _ [] = []
zip [] _ = []
zip (h:t) (x:y) = (h,x) ++ zip t y