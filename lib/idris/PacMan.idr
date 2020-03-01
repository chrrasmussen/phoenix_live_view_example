module PacMan

import Erlang
import PhoenixLiveView
import Data.Nat
import Data.List
import Data.List.Extra
import Control.Pipeline
import Utils

%cg erlang export exports


-- BOARD

data Block = Wall | Empty

W : Block
W = Wall

E : Block
E = Empty

board : List (List Block)
board =
  [ [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W]
  , [W, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, W]
  , [W, E, W, E, W, W, W, E, E, W, W, W, E, E, W, E, E, W, W, W, E, W]
  , [W, E, W, E, W, E, E, W, E, W, E, E, W, E, W, E, W, E, E, E, E, W]
  , [W, E, W, E, W, E, E, W, E, W, W, W, E, E, W, E, E, W, W, E, E, W]
  , [W, E, W, E, W, E, E, W, E, W, E, E, W, E, W, E, E, E, E, W, E, W]
  , [W, E, W, E, W, W, W, E, E, W, E, E, W, E, W, E, W, W, W, E, E, W]
  , [W, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, E, W]
  , [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W]
  ]

rows : Nat
rows = length board

cols : Nat
cols = maybe 0 length (head' board)

indexedBoard : List (Nat, List (Nat, Block))
indexedBoard =
  zip [0..minus rows 1]
    (map (zip [0..minus cols 1]) board)


-- BOARD VIEW

blockSize : Double
blockSize = 25

blockType : Block -> ErlAtom
blockType Wall = MkErlAtom "wall"
blockType Empty = MkErlAtom "empty"

boardBlocks : Double -> List ErlMap
boardBlocks widthFactor =
  indexedBoard
    |> concatMap (\(rowIndex, rowValue) => map (\(colIndex, colValue) => blockEntry (colIndex, rowIndex) colValue) (rowValue))
  where
    blockEntry : (Nat, Nat) -> Block -> ErlMap
    blockEntry (x, y) block =
      let blockData =
          Maps.empty
            |> insert (MkErlAtom "type") (blockType block)
            |> insert (MkErlAtom "x") (cast x * widthFactor)
            |> insert (MkErlAtom "y") (cast y * widthFactor)
            |> insert (MkErlAtom "width") widthFactor
      in blockData


-- GAME

tickInterval : Int
tickInterval = 200

data Direction = Up | Right | Down | Left

rotation : Direction -> Int
rotation Up = -90
rotation Right = 0
rotation Down = 90
rotation Left = 180

record GameState where
  constructor MkGameState
  hasStarted : Bool
  heading : Direction
  x : Nat
  y : Nat

arrowKeyToDirection : String -> Maybe Direction
arrowKeyToDirection "ArrowLeft" = Just Left
arrowKeyToDirection "ArrowDown" = Just Down
arrowKeyToDirection "ArrowUp" = Just Up
arrowKeyToDirection "ArrowRight" = Just Right
arrowKeyToDirection _ = Nothing

tickMsg : ErlAtom
tickMsg = MkErlAtom "tick"

scheduleTick : IO ()
scheduleTick = do
  self <- erlSelf
  erlSendAfter tickInterval self tickMsg

blockAtPosition : (Nat, Nat) -> Maybe Block
blockAtPosition (x, y) = do
  row <- index' y board
  index' x row

isValidPosition : (Nat, Nat) -> Bool
isValidPosition (x, y) =
  x < cols && y < rows

nextPosition : (Nat, Nat) -> Direction -> Maybe (Nat, Nat)
nextPosition (x, y) direction =
  (if isValidPosition (nextPosition' direction)
    then Just (nextPosition' direction)
    else Nothing)
  where
    nextPosition' : Direction -> (Nat, Nat)
    nextPosition' Up = (x, minus y 1)
    nextPosition' Right = (x + 1, y)
    nextPosition' Down = (x, y + 1)
    nextPosition' Left = (minus x 1, y)

runTick : GameState -> GameState
runTick gameState@(MkGameState False _ _ _) =
  gameState
runTick gameState@(MkGameState True heading' x' y') =
  let Just (newX, newY) = nextPosition (x', y') heading'
    | _ => gameState
  in let Just Empty = blockAtPosition (newX, newY)
    | _ => gameState
  in record { heading = heading', x = newX, y = newY } gameState


-- PHOENIX LIVE VIEW

Model : Type
Model = GameState

init : IO Model
init = do
  scheduleTick
  pure (MkGameState False Right 1 1)

update : String -> ErlTerm -> Model -> IO Model
update "keydown" params model = do
  let Just direction = erlCase Nothing [MMapSubset ["key" := MAny] Just] params >>= erlTermToString >>= arrowKeyToDirection
    | _ => pure model
  pure (the GameState (record { hasStarted = True, heading = direction } model))
update _ _ model = pure model

view : Model -> View
view model =
  let assigns =
      Maps.empty
        |> insert (MkErlAtom "rotation") (rotation (heading model))
        |> insert (MkErlAtom "x") (cast (x model) * blockSize)
        |> insert (MkErlAtom "y") (cast (y model) * blockSize)
        |> insert (MkErlAtom "width") blockSize
        |> insert (MkErlAtom "blocks") (boardBlocks blockSize)
  in renderTemplate "Elixir.DemoWeb.IdrisView" "pacman.html" assigns

data Msg
  = Tick
  | Unknown

handleInfo : ErlTerm -> Model -> IO Model
handleInfo msg model = do
  let parsedMsg = erlCase Unknown [map (const Tick) (MExact tickMsg)] msg
  case parsedMsg of
    Tick => do
      scheduleTick
      pure (runTick model)
    Unknown =>
      pure model


exports : ErlExport
exports =
  exportPhoenixLiveView "Elixir.DemoWeb.Idris.PacMan" init update view handleInfo
