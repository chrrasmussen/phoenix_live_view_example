module Utils

import Erlang

namespace Concurrency
  export
  erlSendAfter : ErlType a => (ms : Int) -> ErlPid -> a -> IO ()
  erlSendAfter delay receiver value = do
    erlCall "erlang" "send_after" [delay, receiver, value]
    pure ()
