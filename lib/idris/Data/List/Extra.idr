module Data.List.Extra

export
head' : List a -> Maybe a
head' [] = Nothing
head' (x :: xs) = Just x

export
index' : Nat -> List a -> Maybe a
index' _ [] = Nothing
index' 0 (x :: _) = Just x
index' (S k) (_ :: xs) = index' k xs

export
range : Nat -> Nat -> List Nat
range from to =
  if from <= to
    then from :: range (S from) to
    else []

export
zipWith : (a -> b -> c) -> List a -> List b -> List c
zipWith func [] _ = []
zipWith func _ [] = []
zipWith func (x :: xs) (y :: ys) = func x y :: zipWith func xs ys

export
zip : List a -> List b -> List (a, b)
zip xs ys = zipWith (\x, y => (x, y)) xs ys
