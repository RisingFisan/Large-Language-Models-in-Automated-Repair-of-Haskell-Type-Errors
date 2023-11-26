type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((x,y):z) | y > 0 = x : converteMSet [(x,y-1):z]
                       | otherwise = converteMSet z