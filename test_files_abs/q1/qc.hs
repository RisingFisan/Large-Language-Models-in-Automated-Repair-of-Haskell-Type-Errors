import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_zip :: [Int] -> [Int] -> Bool
prop_zip xs ys = f xs ys == correctZip xs ys

correctZip :: [a] -> [b] -> [(a, b)]
correctZip _ [] = []
correctZip [] _ = []
correctZip (h:t) (x:y) = (h,x) : correctZip t y

main = do
    r <- quickCheckResult prop_zip 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)