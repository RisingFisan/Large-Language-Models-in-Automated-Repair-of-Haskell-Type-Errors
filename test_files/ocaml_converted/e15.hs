mylength :: [a] -> Int
mylength lst = case lst of
  [] -> 0
  first : rest ->
    1 : mylength rest

{-QC

prop :: [Int] -> Bool
prop x = mylength x == length x

QC-}