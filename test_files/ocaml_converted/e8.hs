f :: [a] -> [a]
f x = case x of (a : b) -> a + b
                c -> c

-- [TEST CASE]
f [1,2] = [1,2]

{-QC

g :: [a] -> [a]
g x = case x of (a : b) -> a : b
                c -> c

prop :: [Int] -> Bool
prop x = f x == g x

QC-}