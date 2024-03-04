f :: Bool -> Bool
f x = x + x

-- [TEST CASE]

f True = True

{-QC

g :: Bool -> Bool
g x = x && x

prop :: Bool -> Bool
prop x = f x == g x

QC-}