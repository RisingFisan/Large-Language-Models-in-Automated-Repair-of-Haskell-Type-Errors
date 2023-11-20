import Test.QuickCheck

-- import Prelude hiding (zip)

-- zip :: [a] -> [b] -> [(a,b)]
-- zip _ [] = []
-- zip [] _ = []
-- zip (h:t) (x:y) = (h,x) : zip t (x:y)

prop_zip :: [Int] -> [Int] -> Bool
prop_zip xs ys = zip xs ys == correctZip xs ys

correctZip :: [a] -> [b] -> [(a, b)]
correctZip _ [] = []
correctZip [] _ = []
correctZip (h:t) (x:y) = (h,x) : correctZip t y

main :: IO ()
main = quickCheck prop_zip