type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((h,hs):t) | hs == 0 = converteMSet t
                        | otherwise = 'h' ++ converteMSet ((h,hs-1):t)