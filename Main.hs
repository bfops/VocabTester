module Main (main) where

import Prelude ()
import Util.Prelewd hiding (drop, length, splitAt, null)

import Control.Exception(bracket)
import Control.Monad.State hiding (fix)
import Data.Sequence
import qualified Data.Text as T
import Data.Either
import Data.Tuple
import Text.Show

import Util.IO

import Text.Parsec.Text
import Text.Parsec.Char
import Text.Parsec.Combinator
import Text.Parsec.Prim hiding (State)

type Trans = (T.Text, T.Text)

-- | Translations between words.
data Dictionary = Dictionary { lang :: Trans          -- ^ The dictionary language
                             , cats :: Seq Category -- ^ Sections of the dictionary (e.g. nouns, verbs)
                             }
    deriving (Show)

data Category = Category { name    :: T.Text      -- ^ Category name
                         , entries :: Seq Trans -- ^ Dictionary entries
                         }
    deriving (Show)

(<+>) :: Parser [a] -> Parser [a] -> Parser [a]
(<+>) = liftA2 (++)

-- Repeatedly run a parser (collecting results in an array) until it fails.
-- Failing will not consume input.
untilFail :: Parser a -> Parser [a]
untilFail = many . try

phrase :: Parser T.Text
phrase = (T.pack . concat <$> untilFail prefixWord) >>= spaced
    where prefixWord = many (oneOf sepChars) <+> many1 (noneOf endChars)
          endChars = "\\\n\r\f|{}" ++ sepChars
          spaced x = spaces >> return x
          sepChars = " \t"

-- like the `string` parser, but for Text
text :: String -> Parser T.Text
text = (T.pack <$>) . string

parser :: Parser Dictionary
parser = spaces >> Dictionary <$> between (spaceChar '{') (spaceChar '}') assoc <*> (fromList <$> untilFail section)
    where
          section = Category <$> prefix (text "\\") <*> (fromList <$> untilFail assoc)
          assoc = (,) <$> phrase <*> prefix (text "|")
          prefix x = x >> spaces >> phrase
          spaceChar c = text [c] >> spaces

-- remove an index from a sequence. O(log(min(i, n-i))).
remove :: Int -> Seq a -> Seq a
remove = uncurry ((><) .$ drop 1) $$ splitAt

-- last valid index of a sequence
lastI :: Seq a -> Int
lastI s = length s - 1

--the interval of valid indices in the sequence
interval :: Seq a -> (Int, Int)
interval s = (0, lastI s)

--while loop for monads
whileM :: Monad m => (a -> Bool) -> (a -> m a) -> a -> m a
whileM p f = iff <$> p <*> (whileM p f =<<).f <*> return

--do while loop for monads
doWhileM :: Monad m => (a -> Bool) -> (a -> m a) -> a -> m a
doWhileM p f x = f x >>= whileM p f

-- generator for a range
rangeGen :: RandomGen g => (Int, Int) -> State g Int
rangeGen = state . randomR

--generate only indices of categories with entries in them.
nonEmptyIGen :: RandomGen g => Seq Category -> State g Int
nonEmptyIGen s = doWhileM (null . entries . index s) (const.rangeGen $ interval s) 0

-- getLine with some prompt text
getStrLn :: String -> IO String
getStrLn s = putStr s >> hFlush stdout >> getLine

runQuiz :: Dictionary -> IO ()
runQuiz = (getStdGen >>=) . runQuiz'
    where runQuiz' d g = whileM (any (not . null . entries) . cats . fst)
                                (ioStep . randStep)
                                (d, g)
                       >> putStrLn "Finished the dictionary!"

          randStep (d, g) = flip runState g $ do i <- nonEmptyIGen $ cats d
                                                 let c = index (cats d) i
                                                 j <- rangeGen.interval $ entries c
                                                 s <- rangeGen (0, 1)
                                                 let f = if s == 0
                                                         then swap
                                                         else id
                                                 return (name c, f $ index (entries c) j, f $ lang d, fix d i j)
                                                 
          ioStep ((n, e, l, d), g) = prompt n e l >> return (d, g)

          prompt n (q, a) (from, to) = do putStrLn $ "Language: " ++  T.unpack from ++ " -> " ++ T.unpack to
                                          putStrLn $ "Category: " ++ T.unpack n
                                          putStrLn $ "  Phrase: " ++ T.unpack q
                                          getStrLn $ "   Guess: "
                                          putStrLn $ "  Answer: " ++ T.unpack a
                                          putStrLn ""

          fix d i j = d { cats = adjust (fix' j) i $ cats d }
          fix' j c = c { entries = remove j $ entries c }

main :: IO ()
main = getArgs >>= maybe (putStrLn "Provide a dictionary name") parseFile . head
    where parseFile file = bracket (openFile file ReadMode) hClose tryQuizFromFile
          tryQuizFromFile h = hGetContents h >>= tryQuiz . parse parser "" . T.pack
          tryQuiz = either (putStrLn . ("Error parsing dictionary " ++) . show) runQuiz
