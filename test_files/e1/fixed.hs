type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((a,b):t) 
    | b == 1 = a : converteMSet t
    | otherwise = a : converteMSet ((a,b-1):t)