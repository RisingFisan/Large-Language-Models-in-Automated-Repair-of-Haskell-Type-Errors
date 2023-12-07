import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_reverse :: [Int] -> Bool
prop_reverse xs = f xs == reverse xs

main = do
    r <- quickCheckResult prop_reverse 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
