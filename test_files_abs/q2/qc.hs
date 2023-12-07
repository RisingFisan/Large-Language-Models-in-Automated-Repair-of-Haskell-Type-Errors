import Test.QuickCheck
import System.Exit

-- [INSERT]

prop_tails :: [Int] -> Bool
prop_tails xs = f xs == correctTails xs

correctTails :: [a] -> [[a]]
correctTails [] = [[]]
correctTails l = l : correctTails (tail l)

main :: IO ()
main = do
    r <- quickCheckResult prop_tails 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)