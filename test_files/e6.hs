type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((x,n):t)
    | n == 0 = converteMSet t
    | otherwise = x ++ converteMSet ((x,n-1):t)

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