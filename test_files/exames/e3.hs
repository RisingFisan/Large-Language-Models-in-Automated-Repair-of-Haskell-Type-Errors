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