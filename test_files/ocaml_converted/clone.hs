clone x n =
   if n <= 0 then [] else x : clone (n-1)

{-QC

prop :: [Int] -> Bool
prop x = clone x (length x) == x

QC-}