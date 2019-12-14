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
