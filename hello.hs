import Data.List (nub)

-- função que soma uma lista

group :: Eq a => [a] -> [[a]]
group [] = []
group (h:t) = insere h (group t)

insere :: Eq a => a -> [[a]] -> [[a]]
insere x [] = [x]
insere x (h:t)
    | x `elem` h = (x : h) : t
    | otherwise = [x] : (h : t)
    
-- myreverse :: [a] -> [a]
-- myreverse [] = []
-- myreverse (h:t) = myreverse t ++ h

-- f x = (&&) x (x + x)

-- main :: IO ()
-- main = do
--     putStrLn "Hello World!"
