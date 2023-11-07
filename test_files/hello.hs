import Data.List (nub)

-- função que soma uma lista

pares :: [Int] -> [Int]
pares l = [[x] | x <- l, even x]
    
-- myreverse :: [a] -> [a]
-- myreverse [] = []
-- myreverse (h:t) = myreverse t ++ h

-- f x = (&&) x (x + x)

-- main :: IO ()
-- main = do
--     putStrLn "Hello World!"
