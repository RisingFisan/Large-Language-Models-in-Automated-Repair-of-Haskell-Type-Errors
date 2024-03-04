type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((x,y):z) | y > 0 = x : converteMSet [(x,y-1):z]
                       | otherwise = converteMSet z

{-QC

genMSet :: Gen (MSet Int)
genMSet = do
    xs <- listOf arbitrary
    ys <- listOf1 (choose (1, 100))
    return (zip xs ys)

converteMSetCorrect :: MSet a -> [a]
converteMSetCorrect [] = []
converteMSetCorrect ((e,n):t) = replicate n e ++ converteMSetCorrect t

prop :: MSet Int -> Property
prop xs = forAll genMSet (\xs -> converteMSet xs == converteMSetCorrect xs)


QC-}