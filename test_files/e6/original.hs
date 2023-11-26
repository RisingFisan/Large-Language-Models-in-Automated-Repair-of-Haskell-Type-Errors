type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((x,n):t)
    | n == 0 = converteMSet t
    | otherwise = x ++ converteMSet ((x,n-1):t)