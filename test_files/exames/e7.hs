type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((h1,h2):t) = replicate h2 h1 : converteMSet t