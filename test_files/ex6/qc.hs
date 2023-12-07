import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_pares :: [Int] -> Bool
prop_pares xs = pares xs == filter even xs

main = do
    r <- quickCheckResult prop_pares 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
