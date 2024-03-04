type MSet a = [(a,Int)]

uniaoMSet :: Eq a => MSet a -> MSet a -> MSet a
uniaoMSet [] l = l
uniaoMSet l [] = l
uniaoMSet l s = foldl somaMSet l s

somaMSet :: Eq a => MSet a -> (a,Int) -> MSet a
somaMSet [] m = [m]
somaMSet (h:t) (x,m) 
    | x == fst h = (x, snd h + m) : t
    | otherwise = h : somaMSet t x

{-QC

import Data.List (sort)

genMSet :: Gen (MSet Int)
genMSet = do
    xs <- listOf arbitrary
    ys <- listOf1 (choose (1, 100))
    return (zip xs ys)

uniaoMSetCorrect :: Eq a => MSet a -> MSet a -> MSet a
uniaoMSetCorrect [] l = l
uniaoMSetCorrect l [] = l
uniaoMSetCorrect l s = foldl somaMSetCorrect l s

somaMSetCorrect :: Eq a => MSet a -> (a,Int) -> MSet a
somaMSetCorrect [] m = [m]
somaMSetCorrect (h:t) (x,m) 
    | x == fst h = (x, snd h + m) : t
    | otherwise = h : somaMSetCorrect t (x, m)

prop :: Property
prop = forAll genMSet (\xs ys -> sort (uniaoMSet xs ys) == sort (uniaoMSetCorrect xs ys))


QC-}