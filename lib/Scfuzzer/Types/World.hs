module Scfuzzer.Types.World where

import Data.Set (Set)

import EVM.Types (Addr, FunctionSelector)

import Scfuzzer.Types.Signature (SignatureMap)
import Scfuzzer.Events (EventMap)

-- | The world is composed by:
--    * A list of "human" addresses
--    * A high-priority map of signatures from every contract
--    * A low-priority map of signatures from every contract
--    * A list of function hashes from payable functions
data World = World
  { senders          :: Set Addr
  , highSignatureMap :: SignatureMap
  , lowSignatureMap  :: Maybe SignatureMap
  , payableSigs      :: [FunctionSelector]
  , eventMap         :: EventMap
  }
  deriving Show
