module PhoenixLiveView

import Erlang


-- RENDER

export
data View : Type where

viewToErlTerm : View -> ErlTerm
viewToErlTerm x = believe_me x

erlTermToView : ErlTerm -> View
erlTermToView x = believe_me x

export
renderTemplate : String -> String -> ErlMap -> View
renderTemplate viewModule templateName assigns = unsafePerformIO $ do
  term <- erlUnsafeCall ErlTerm viewModule "render" [templateName, assigns]
  pure $ erlTermToView term


-- HELPERS

socketAssign : (ErlType key, ErlType value) => key -> value -> ErlTerm -> ErlTerm
socketAssign key value socket = unsafePerformIO $
  erlUnsafeCall ErlTerm "Elixir.Phoenix.LiveView" "assign" [socket, key, value]

socketUpdate : (ErlType key, ErlType value) => key -> (ErlTerm -> value) -> ErlTerm -> ErlTerm
socketUpdate key func socket = unsafePerformIO $
  erlUnsafeCall ErlTerm "Elixir.Phoenix.LiveView" "update" [socket, key, func]

socketGet : (ErlType key) => key -> ErlTerm -> Maybe ErlTerm
socketGet key socket = do
  assigns <- map (erlUnsafeCast ErlMap) (lookup (MkAtom "assigns") any (erlUnsafeCast ErlMap socket))
  lookup key any assigns


-- LIFE-CYCLE

modelKey : ErlAtom
modelKey = MkAtom "idris_model"

mount : IO model -> ErlTerm -> ErlTerm -> ErlTerm -> IO ErlTerm
mount init params session socket = do
  modelData <- init
  let newSocket = socketAssign modelKey (MkRaw modelData) socket
  pure $ cast $ MkTuple2 (MkAtom "ok") newSocket

handleEvent : (String -> ErlTerm -> model -> IO model) -> String -> ErlTerm -> ErlTerm -> IO ErlTerm
handleEvent update event unsignedParams socket = do
  let Just term = socketGet modelKey socket
  let MkRaw modelData = (erlUnsafeCast (Raw model) term)
  newModelData <- update event unsignedParams modelData
  let newSocket = socketAssign modelKey (MkRaw newModelData) socket
  pure $ cast $ MkTuple2 (MkAtom "noreply") newSocket

handleInfo : (ErlTerm -> model -> IO model) -> ErlTerm -> ErlTerm -> IO ErlTerm
handleInfo infoHandler msg socket = do
  let Just term = socketGet modelKey socket
  let MkRaw modelData = erlUnsafeCast (Raw model) term
  newModelData <- infoHandler msg modelData
  let newSocket = socketAssign modelKey (MkRaw newModelData) socket
  pure $ cast $ MkTuple2 (MkAtom "noreply") newSocket

render : (model -> View) -> ErlMap -> ErlTerm
render view assigns =
  let Just (MkRaw modelData) = map (erlUnsafeCast (Raw model)) (lookup modelKey any assigns)
  in viewToErlTerm (view modelData)


-- DEFAULT HANDLERS

export
skipHandleInfo : ErlTerm -> model -> IO model
skipHandleInfo msg model = pure model


-- EXPORT

liveDefinition : String -> IO ErlTerm
liveDefinition moduleName =
  erlUnsafeCall ErlTerm "Elixir.Phoenix.LiveView" "__live__" [MkAtom moduleName, the ErlNil Nil]

export %inline
exportPhoenixLiveView :
  String ->
  (init : IO model) ->
  (update : String -> ErlTerm -> model -> IO model) ->
  (view : model -> View) ->
  (handleInfo : ErlTerm -> model -> IO model) ->
  ErlExport
exportPhoenixLiveView moduleName init update view infoHandler =
  Fun "__live__" (MkIOFun0 (liveDefinition moduleName)) <+>
    Fun "mount" (MkIOFun3 (mount init)) <+>
    Fun "handle_event" (MkIOFun3 (handleEvent update)) <+>
    Fun "handle_info" (MkIOFun2 (handleInfo infoHandler)) <+>
    Fun "render" (MkFun1 (render view))
