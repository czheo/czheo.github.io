-- | Implies
-- >>> True ==> False
-- False
--
-- >>> False ==> True
-- True
(==>) :: Bool -> Bool -> Bool
True ==> False = False
_ ==> _ = True

newtype Set a = Set {list :: [a]} deriving (Show)

-- | forall
-- >>> forall (Set [1,2,3]) (>0)
-- True
--
-- >>> forall (Set [0,2,3]) (>0)
-- False
forall = flip all . list

-- | exists
-- >>> exists (Set [1,2,3]) (<0)
-- False
--
-- >>> exists (Set [0,2,3]) (>0)
-- True
exists = flip any . list

-- | subset
-- >>> Set [1, 2] `subset` Set [1, 2, 3]
-- True
--
-- >>> Set [1, 2] `subset` Set [1, 3]
-- False
s `subset` t = forall s (\x -> x `elem` list t)

-- | eq
-- >>> Set [1, 2] `eq` Set [1, 2, 1]
-- True
--
-- >>> Set [1, 2] `eq` Set [1, 3]
-- False
s `eq` t = s `subset` t && t `subset` s

-- | sizeof
-- >>> sizeof $ Set [1, 2]
-- 2
--
-- >>> sizeof $ Set [1, 2, 1]
-- 2
sizeof :: (Eq a) => Set a -> Int
sizeof = length . uniq . list
    where uniq [] = []
          uniq (x:xs)
               | x `elem` uniq xs = uniq xs
               | otherwise = x : uniq xs
