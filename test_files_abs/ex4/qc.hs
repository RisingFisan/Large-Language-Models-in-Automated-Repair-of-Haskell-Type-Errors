import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_emptyList :: [Int] -> Bool
prop_emptyList xs = f xs == null xs

main = do
    r <- quickCheckResult prop_emptyList 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
