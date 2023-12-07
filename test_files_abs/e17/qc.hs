import Test.QuickCheck
import System.Exit

-- [INSERT]

funcCorrect :: [[Int]] -> [Int]
funcCorrect l = concat (filter (\x -> sum x > 10) l)

prop_func :: [[Int]] -> Bool
prop_func xs = f xs == funcCorrect xs

main = do
    r <- quickCheckResult prop_func 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
