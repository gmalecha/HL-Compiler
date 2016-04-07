module Demo.Logic where

import Control.Monad.Logic

odds :: MonadPlus m => m Int
odds = (return 1) `mplus` (odds >>= \a -> return (2 + a))

someEvens :: MonadPlus m => m Int
someEvens = (return 2) `mplus` (return 4) `mplus` (return 6)

-- as expected, (observe unfair) never terminates
unfair :: MonadPlus m => m Int
unfair = do
   x <- odds `mplus` someEvens
   if (even x)
      then
      return x
      else
      mzero

-- as expected,  (observe fair) returns 2
fair :: (MonadPlus m, MonadLogic m) => m Int
fair = do
   x <- odds `interleave` someEvens
   if (even x)
      then
      return x
      else
      mzero

-- (observe fairButBad) never terminates. This is because the else block never
-- terminates. This shows that LogicT is only *really* useful when failure
-- cases always terminate. Since we're doing infinite depth search, I don't
-- believe that this is terribly useful for us
fairButBad :: (MonadPlus m, MonadLogic m) => m Int
fairButBad = do
   x <- odds `interleave` someEvens
   if (even x)
      then
      return x
      else
      do
         guard (even (length [0..]))
         return x
