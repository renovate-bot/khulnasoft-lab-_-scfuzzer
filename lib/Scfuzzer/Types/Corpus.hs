module Scfuzzer.Types.Corpus where

import Data.Set (Set, size)
import Scfuzzer.Types.Tx (Tx)

type Corpus = Set (Int, [Tx])

corpusSize :: Corpus -> Int
corpusSize = size
