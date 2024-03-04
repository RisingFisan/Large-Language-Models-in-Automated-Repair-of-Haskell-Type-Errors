
conslst :: [a] -> [b] -> [(a,b)]
conslst lst1 lst2 = case lst1 of
  [] -> []
  (fst:rest) -> case lst2 of
    [] -> []
    (fst2:rest2) -> (fst:fst2) : (conslst rest rest2)

-- [TEST CASE]

conslst [1] [2] = [(1,2)]

{-QC

cconslst :: [a] -> [b] -> [(a,b)]
cconslst lst1 lst2 = case lst1 of
  [] -> []
  (fst:rest) -> case lst2 of
    [] -> []
    (fst2:rest2) -> (fst, fst2) : (cconslst rest rest2)

prop :: [Int] -> [Int] -> Bool
prop xs ys = conslst xs ys == cconslst xs ys

QC-}