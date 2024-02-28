type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((a,b):t) 
    | b == 1 = a : converteMSet [t]
    | otherwise = a : converteMSet ((a,b-1):t)

{-QC

genMSet :: Gen (MSet Int)
genMSet = do
    xs <- listOf arbitrary
    ys <- listOf1 (choose (1, 100))
    return (zip xs ys)

converteMSetCorrect :: MSet a -> [a]
converteMSetCorrect [] = []
converteMSetCorrect ((e,n):t) = replicate n e ++ converteMSetCorrect t

prop :: Property
prop = forAll genMSet (\xs -> converteMSet xs == converteMSetCorrect xs)


QC-}