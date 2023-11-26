type MSet a = [(a,Int)]

converteMSet :: MSet a -> [a]
converteMSet [] = []
converteMSet ((x,xs):y) = if xs == 1 then x : converteMSet y else x : converteMSet ((x,xs-1),y)