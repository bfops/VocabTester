-- | Functions for dealing with non-pure or non-lazy computations
module Util.IO ( module IO
               , module Env
               , module Rand
               , undefined
               , void
               , forever
               ) where

import Prelude (undefined)

import Control.Monad
import System.IO as IO
import System.Environment as Env
import System.Random as Rand
