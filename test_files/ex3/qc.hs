import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_sum :: [Int] -> Bool
prop_sum xs = mysum xs == sum xs

main = do
    r <- quickCheckResult prop_sum 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
