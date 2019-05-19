module Control.Pipeline

-- SOURCE: https://github.com/idris-lang/Idris-dev/blob/master/libs/contrib/Control/Pipeline.idr

infixl 9 |>
infixr 0 <|


||| Pipeline style function application, useful for chaining
||| functions into a series of transformations, reading top
||| to bottom.
|||
||| ```idris example
||| [[1], [2], [3]] |> join |> map (* 2)
||| ```
public export
(|>) : a -> (a -> b) -> b
a |> f = f a


||| Backwards pipeline style function application, similar to $.
|||
||| ```idris example
||| unpack <| "hello" ++ "world"
||| ```
public export
(<|) : (a -> b) -> a -> b
f <| a = f a