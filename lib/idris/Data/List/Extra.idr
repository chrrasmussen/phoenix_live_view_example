module Data.List.Extra

export
index' : Nat -> List a -> Maybe a
index' _ [] = Nothing
index' 0 (x :: _) = Just x
index' (S k) (_ :: xs) = index' k xs
