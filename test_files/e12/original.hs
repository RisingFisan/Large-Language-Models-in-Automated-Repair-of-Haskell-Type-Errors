type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((a,n):t) = show (replicate n a ++ converteMSet t)