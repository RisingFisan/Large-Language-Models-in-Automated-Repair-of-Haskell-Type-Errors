import Test.QuickCheck
import System.Exit

-- [INSERT]

genMSet :: Gen (MSet Int)
genMSet = do
    xs <- listOf arbitrary
    ys <- listOf1 (choose (1, 100))
    return (zip xs ys)

removeMSetCorrect :: Eq a => a -> MSet a -> MSet a
removeMSetCorrect _ [] = []
removeMSetCorrect a ((e,n):t)
    | a == e && n > 0 = (e,n-1) : t
    | a == e = t
    | otherwise = (e,n) : removeMSetCorrect a t

prop_removeMSet :: Int -> MSet Int -> Property
prop_removeMSet x xs = forAll genMSet (\xs -> f x xs == removeMSetCorrect x xs)

main = do
    r <- quickCheckResult prop_removeMSet 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
