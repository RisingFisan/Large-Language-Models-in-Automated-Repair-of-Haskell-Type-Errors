func :: [[Int]] -> [Int]
func [] = []
func (h:t) = if sum h > 10 then h : func t else func t