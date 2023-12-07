import Test.QuickCheck
import System.Exit

-- [INSERT]

genMSet :: Gen (MSet Int)
genMSet = do
    xs <- listOf arbitrary
    ys <- listOf1 (choose (1, 100))
    return (zip xs ys)

converteMSetCorrect :: MSet a -> [a]
converteMSetCorrect [] = []
converteMSetCorrect ((e,n):t) = replicate n e ++ converteMSetCorrect t

prop_convertMSet :: MSet Int -> Property
prop_convertMSet xs = forAll genMSet (\xs -> f xs == converteMSetCorrect xs)

main = do
    r <- quickCheckResult prop_convertMSet 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
