type MSet a = [(a,Int)]

f :: MSet a -> [a]
f [] = []
f ((x,xs):y) = if xs == 1 then x : f y else x : f ((x,xs-1),y)