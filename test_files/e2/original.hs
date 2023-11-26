type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((a,0):t) = converteMSet t
converteMSet ((a,b):t) = a ++ converteMSet ((a,b-1):t)