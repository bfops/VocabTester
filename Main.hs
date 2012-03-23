module Main (main) where

import Control.Exception(bracket)
import Control.Monad
import Data.Function
import Data.List
import System.IO
import System.Environment

import Text.Parsec.String
import Text.Parsec.Char
import Text.Parsec.Combinator
import Text.Parsec.Prim

-- | Translations between words.
data Dictionary = Dictionary { lang :: (String, String) -- ^ The dictionary language
                             , cats :: [Category]       -- ^ Sections of the dictionary (e.g. nouns, verbs)
                             }
    deriving (Show)

data Category = Category { name    :: String             -- ^ Category name
                         , entries :: [(String, String)] -- ^ Dictionary entries
                         }
    deriving (Show)

phrase :: Parser String
phrase = many $ noneOf "\\\n\r\f|{}"

parser :: Parser Dictionary
parser = flip (liftM2 Dictionary) (many section) $ (on between $ ignoreSpaces . (:[]) . char) '{' '}' assoc
    where 
          section = liftM2 Category (ignoreSpaces [string "\\", phrase]) (many assoc)
          assoc = liftM2 (,) (ignoreSpaces [phrase]) (ignoreSpaces [string "|", phrase])
          ignoreSpaces xs = (foldl1' (>>) $ map (spaces >>) xs) >>= ((spaces >>).return)

quiz :: Dictionary -> IO ()
quiz = putStr . show

main :: IO ()
main = do args <- getArgs
          case args of
            [] -> putStrLn "Provide a dictionary name!"
            file:_ -> bracket (openFile file ReadMode)
                              hClose
                              ((tryQuiz . parse parser "" =<<) . hGetContents)
    where tryQuiz = flip either quiz $ putStrLn . ("Error parsing dictionary: " ++) . show
