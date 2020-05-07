module Main where

import Parser
import Control.Applicative
import Data.Char

type Output = String

data Memory = Memory [Int] [Int]

instance Show Memory where
    show (Memory ls (r:rs)) =
        let left  = unwords . map show . reverse $ ls
            right = unwords . map show $ rs
            curr  = " ->" ++ show r ++ "<- "
         in "Memory " ++ left ++ curr ++ right
    show (Memory ls _) =
        "Memory" ++ (unwords . map show . reverse $ ls)

data Instruction = ShiftL
                 | ShiftR
                 | Inc
                 | Dec
                 | Output
                 | Input
                 | Loop [Instruction]
                 deriving Show

emptyMemory :: Memory
emptyMemory = Memory [] []

shiftLeft :: Memory -> Memory
shiftLeft (Memory (l:ls) rs) = Memory ls (l:rs)
shiftLeft (Memory []     rs) = Memory [] (0:rs)

shiftRight :: Memory -> Memory
shiftRight (Memory ls (r:rs)) = Memory (r:ls) rs
shiftRight (Memory ls [])     = Memory (0:ls) []

modifyMemory :: (Int -> Int) -> Memory -> Memory
modifyMemory f (Memory ls (r:rs)) = Memory ls (f r : rs)
modifyMemory f (Memory ls [])     = Memory ls [f 0]

readMemory :: Memory -> Int
readMemory (Memory _ (r:_)) = r
readMemory (Memory _ [])    = 0

parseInstruction :: Parser Instruction
parseInstruction =
    foldl1 (<|>) [ ShiftL <$ char '<'
                 , ShiftR <$ char '>'
                 , Inc    <$ char '+'
                 , Dec    <$ char '-'
                 , Input  <$ char ','
                 , Output <$ char '.'
                 , Loop   <$>
                     (char '[' *>
                     some parseInstruction
                     <* char ']')
                 ]

parseCode :: Parser [Instruction]
parseCode = some parseInstruction <* (char '\n' <|> pure '0') <* eof

run :: Memory -> [Instruction] -> IO Memory
run mem [] = return mem
run mem (i:is) =
    case i of
      ShiftL  -> run (shiftLeft         mem) is
      ShiftR  -> run (shiftRight        mem) is
      Inc     -> run (modifyMemory succ mem) is
      Dec     -> run (modifyMemory pred mem) is
      Input   -> do
          c <- ord <$> getChar
          run (modifyMemory (const c) mem) is
      Output  -> do
          putChar . chr . readMemory $ mem
          run mem is
      Loop ls ->
          case (readMemory mem) of
            0 -> run mem is
            _ -> run mem ls >>= flip run (i:is)

main = do
    code <- getContents
    let instrs = snd . maybe ("", []) id . runParser parseCode $ code
    run emptyMemory instrs >>= print
