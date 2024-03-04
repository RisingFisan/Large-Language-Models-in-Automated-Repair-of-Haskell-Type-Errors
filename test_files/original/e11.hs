type MSet a = [(a,Int)]

removeMSet :: Eq a => a -> MSet a -> MSet a
removeMSet _ [] = []
removeMSet m ((a,b):xs) = if m == a
                          then if b == 1
                               then [xs]
                               else (a,b-1):xs
                          else (a,b):removeMSet m xs

{-QC

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

prop :: Int -> MSet Int -> Property
prop x xs = forAll genMSet (\xs -> removeMSet x xs == removeMSetCorrect x xs)


QC-}