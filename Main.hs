module Main (main) where

import Control.Applicative((<$>),(<*>))
import Control.Exception(bracket)
import qualified Data.Sequence as S
import Data.Foldable hiding (concat)
import Data.Singleton
import qualified Data.Text as T
import Data.Tuple
import System.IO
import System.Environment
import System.Random

import Text.Parsec.Text
import Text.Parsec.Char
import Text.Parsec.Combinator
import Text.Parsec.Prim

-- | Translations between words.
data Dictionary = Dictionary { lang :: (T.Text, T.Text) -- ^ The dictionary language
                             , cats :: S.Seq Category   -- ^ Sections of the dictionary (e.g. nouns, verbs)
                             }
    deriving (Show)

data Category = Category { name    :: T.Text                 -- ^ Category name
                         , entries :: S.Seq (T.Text, T.Text) -- ^ Dictionary entries
                         }
    deriving (Show)

(<+>) :: Parser [a] -> Parser [a] -> Parser [a]
(<+>) x y = (++) <$> x <*> y

-- Repeatedly run a parser (collecting results in an array) until it fails.
-- Failing will not consume input.
untilFail :: Parser a -> Parser [a]
untilFail = many . try

phrase :: Parser T.Text
phrase = (T.pack . concat <$> untilFail prefixWord) >>= (\x -> spaces >> return x)
    where prefixWord = many (oneOf sepChars) <+> many1 (noneOf endChars)
          endChars = "\\\n\r\f|{}" ++ sepChars
          sepChars = " \t"

text :: String -> Parser T.Text
text = fmap T.pack . string

parser :: Parser Dictionary
parser = spaces >> Dictionary <$> between (spaceChar '{') (spaceChar '}') assoc <*> (S.fromList <$> untilFail section)
    where
          section = Category <$> prefix (text "\\") <*> (S.fromList <$> untilFail assoc)
          assoc = (,) <$> phrase <*> prefix (text "|")
          prefix x = x >> spaces >> phrase
          spaceChar c = text [c] >> spaces

remove :: Int -> S.Seq a -> S.Seq a
remove i s = (S.><) pre $ S.drop 1 post
    where (pre, post) = S.splitAt i s

lastI :: S.Seq a -> Int
lastI s = S.length s - 1

quiz :: Dictionary -> IO ()
quiz = (getStdGen >>=) . quiz'
    where quiz' d g = if S.null . foldr' ((S.><) . entries) S.empty $ cats d
                      then putStrLn "Finished the dictionary!"
                      else quizCatRand d g

          quizCatRand d g = let (i, g') = randomR (0, lastI $ cats d) g
                            in quiz'' d i g' $ S.index (cats d) i

          quiz'' d i g c = if S.null $ entries c
                           then quizCatRand d g
                           else let (j, g') = randomR (0, lastI $ entries c) g
                                in prompt g' (S.index (entries c) j) >>= quiz' (fix d i j)

          considerSwap g e = let (i, g') = randomR (0, 1) g
                             in (g', if i == (0 :: Int)
                                     then e
                                     else swap e)

          prompt g e = let (g', (q, a)) = considerSwap g e
                       in putStrLn (T.unpack q)
                       >> getLine
                       >> putStrLn (T.unpack a)
                       >> putStrLn ""
                       >> return g'

          fix d i j = d { cats = S.adjust (fix' j) i $ cats d }
          fix' j c = c { entries = remove j $ entries c }

main :: IO ()
main = getArgs >>= single (putStrLn "Provide a dictionary name") parseFile
    where parseFile file = bracket (openFile file ReadMode) hClose quizFile
          tryQuiz = either (putStrLn . ("Error parsing dictionary " ++) . show) quiz
          quizFile h = hGetContents h >>= (tryQuiz . parse parser "" . T.pack)
