f :: [Bool] -> Bool
f lst = case lst of
  [] -> True
  (fst:rest) -> fst
  (fst:snd:rest) -> 4

-- [TEST CASE]

f [False] = False

{-QC

ff :: [Bool] -> Bool
ff lst = case lst of
  [] -> True
  (fst:rest) -> fst
  (fst:snd:rest) -> False

prop :: [Bool] -> Bool
prop x = f x == ff x

QC-}