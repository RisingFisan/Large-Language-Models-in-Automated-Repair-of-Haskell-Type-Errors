import Test.QuickCheck
import System.Exit

-- [INSERT]

genMSet :: Gen (MSet Int)
genMSet = do
    xs <- listOf arbitrary
    ys <- listOf1 (choose (1, 100))
    return (zip xs ys)

uniaoMSetCorrect :: Eq a => MSet a -> MSet a -> MSet a
uniaoMSetCorrect = foldr insereMSetCorrect

insereMSetCorrect :: Eq a => (a, Int) -> MSet a -> MSet a
insereMSetCorrect a [] = [a]
insereMSetCorrect (x,y) ((e,n):t)
    | x == e = (e,n+y) : t
    | otherwise = (e,n) : insereMSetCorrect (x,y) t

prop_uniaoMSet :: MSet Int -> MSet Int -> Property
prop_uniaoMSet xs ys = forAll genMSet (\xs ys -> uniaoMSet xs ys == uniaoMSetCorrect xs ys)

main = do
    r <- quickCheckResult prop_uniaoMSet 
    case r of
        Success {} -> return ()
        _ -> exitWith (ExitFailure 1)
