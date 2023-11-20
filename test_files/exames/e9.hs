type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((x,y):t)
    | y == 0 = converteMSet t
    | otherwise = "x" ++ converteMSet ((x,y-1):t)