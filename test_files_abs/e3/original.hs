type MSet a = [(a,Int)]

f :: Eq a => MSet a -> MSet a -> MSet a
f [] l = l
f l [] = l
f l s = foldl g l s

g :: Eq a => MSet a -> (a,Int) -> MSet a
g [] m = [m]
g (h:t) (x,m) 
    | x == fst h = (x, snd h + m) : t
    | otherwise = h : g t x