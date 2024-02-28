type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((a,i):xs) = if i == 0 then converteMSet xs
                          else 'a' : converteMSet ((a,i-1):xs)

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