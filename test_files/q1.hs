myzip :: [a] -> [b] -> [(a,b)]
myzip _ [] = []
myzip [] _ = []
myzip (h:t) (x:y) = (h,x) ++ myzip t y

{-QC

prop :: [Int] -> [Int] -> Bool
prop xs ys = myzip xs ys == correctZip xs ys

correctZip :: [a] -> [b] -> [(a, b)]
correctZip _ [] = []
correctZip [] _ = []
correctZip (h:t) (x:y) = (h,x) : correctZip t y

QC-}