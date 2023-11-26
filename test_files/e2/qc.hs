import Test.QuickCheck

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
prop_convertMSet xs = forAll genMSet (\xs -> converteMSet xs == converteMSetCorrect xs)

main = do
    quickCheck prop_convertMSet