module Data.Singleton where

import Data.Maybe

class Singleton f where
    single :: b -> (a -> b) -> f a -> b

instance Singleton [] where
    single b f = single b f . listToMaybe

instance Singleton Maybe where
    single = maybe

instance Singleton (Either a) where
    single = either . const
