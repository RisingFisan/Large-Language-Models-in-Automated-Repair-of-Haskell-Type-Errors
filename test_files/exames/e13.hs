type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((a,i):xs) = if i == 0 then converteMSet xs
                          else 'a' : converteMSet ((a,i-1):xs)