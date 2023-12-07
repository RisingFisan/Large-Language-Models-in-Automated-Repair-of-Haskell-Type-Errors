import Test.QuickCheck
import System.Exit

-- [INSERT]

funcCorrect :: [[Int]] -> [Int]
funcCorrect l = concat (filter (\x -> sum x > 10) l)

prop_func :: [[Int]] -> Property
prop_func xs = not (any null xs) ==> func xs == funcCorrect xs

main = do
    r <- quickCheckResult prop_func 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)