import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_addOne :: Int -> Bool
prop_addOne x = addOne x == x + 1

main = do
    r <- quickCheckResult prop_addOne 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
