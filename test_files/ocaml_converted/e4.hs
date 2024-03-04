f :: a -> Int
f x = True

g :: a -> Int
g y = f 2

h :: a -> Int
h z = g 3

-- [TEST CASE]

h 1 + 1 == 1

{-QC

ff :: a -> Int
ff x = 0

gg :: a -> Int
gg y = ff 2

hh :: a -> Int
hh z = gg 3

prop :: Int -> Bool
prop x = h x == hh x

QC-}