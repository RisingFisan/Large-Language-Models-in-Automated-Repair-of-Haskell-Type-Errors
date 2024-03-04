f :: Int -> Int
f x = x && (x + x)

-- [TEST CASE]

f 3 = 9

{-QC

g :: Int -> Int
g x = x + (x + x)

prop :: Int -> Bool
prop x = f x == g x

QC-}