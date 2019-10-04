import Erlang
import PhoenixLiveView

Model : Type
Model = Int

init : IO Model
init = pure 0

update : String -> ErlTerm -> Model -> IO Model
update "inc" params model = pure $ model + 1
update "dec" params model = pure $ model - 1

view : Model -> View
view model =
  let assigns = insert (MkErlAtom "val") model empty
  in renderTemplate "Elixir.DemoWeb.IdrisView" "counter.html" assigns

exports : ErlExports
exports =
  exportPhoenixLiveView init update view skipHandleInfo
