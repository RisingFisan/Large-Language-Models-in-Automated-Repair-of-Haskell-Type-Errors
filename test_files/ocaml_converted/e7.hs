reverse :: [a] -> [a]
reverse lst = case lst of
  [] -> []
  (x:xs) -> reverse xs ++ x

{-QC

rreverse :: [a] -> [a]
rreverse lst = case lst of
  [] -> []
  (x:xs) -> rreverse xs ++ [x]

prop :: [Int] -> Bool
prop x = reverse x == rreverse x

QC-}