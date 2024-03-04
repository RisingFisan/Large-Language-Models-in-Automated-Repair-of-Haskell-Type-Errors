wwhile (f, b) = 
  let (b', c') = f b in
  if c' == True then wwhile (f b')
  else b'

{-QC

wwwhile (f, b) = 
  let (b', c') = f b in
  if c' == True then wwwhile (f, b')
  else b'

prop :: (Int -> (Int, Bool), Int) -> Bool
prop x = wwhile x == wwwhile x

QC-}