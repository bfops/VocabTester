module Control.Combinator ( pass1, pass2, pass3, pass4
                          , ap1, ap2, ap3, ap4
                          , on1, on2, on3, on4
                          )
    where

import Control.Applicative

pass0 :: (a -> b) -> a -> b
pass1 :: Functor f => (a -> b) -> f a -> f b
pass2 :: (Functor f1, Functor f2) => (a -> b) -> f1 (f2 a) -> f1 (f2 b)
pass3 :: (Functor f1, Functor f2, Functor f3) => (a -> b) -> f1 (f2 (f3 a)) -> f1 (f2 (f3 b))
pass4 :: (Functor f1, Functor f2, Functor f3, Functor f4) => (a -> b) -> f1 (f2 (f3 (f4 a))) -> f1 (f2 (f3 (f4 b)))

pass0 = ($)
pass1 = (<$>)
pass2 = (<$>).(<$>)
pass3 = (<$>).(<$>).(<$>)
pass4 = (<$>).(<$>).(<$>).(<$>)

infixl 4 `pass0`
infixl 4 `pass1`
infixl 4 `pass2`
infixl 4 `pass3`
infixl 4 `pass4`

ap1 :: (a -> b) -> a -> b
ap2 :: (a1 -> a2 -> b) -> a2 -> (a1 -> b)
ap3 :: (a1 -> a2 -> a3 -> b) -> a3 -> (a1 -> a2 -> b)
ap4 :: (a1 -> a2 -> a3 -> a4 -> b) -> a4 -> (a1 -> a2 -> a3 -> b)

ap1 f x = ($x) `pass0` f
ap2 f x = ($x) `pass1` f
ap3 f x = ($x) `pass2` f
ap4 f x = ($x) `pass3` f

infixr 1 `ap1`
infixr 1 `ap2`
infixr 1 `ap3`
infixr 1 `ap4`

on1 :: (a -> b) -> (r -> a) -> (r -> b)
on2 :: (a -> b -> c) -> (r -> b) -> (a -> r -> c)
on3 :: (a -> b -> c -> d) -> (r -> c) -> (a -> b -> r -> d)
on4 :: (a -> b -> c -> d -> e) -> (r -> d) -> (a -> b -> c -> r -> e)

on1 f g = (.g) `pass0` f
on2 f g = (.g) `pass1` f
on3 f g = (.g) `pass2` f
on4 f g = (.g) `pass3` f

infixl 4 `on1`
infixl 4 `on2`
infixl 4 `on3`
infixl 4 `on4`
