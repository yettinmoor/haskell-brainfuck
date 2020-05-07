{-# LANGUAGE ViewPatterns #-}

module Parser where

import Control.Applicative

newtype Parser a = Parser { runParser :: String -> Maybe (String, a)
                          }

instance Functor Parser where
    fmap f (Parser p) =
        Parser $ \input -> p input >>= \(input', a) -> Just (input', f a)

instance Applicative Parser where
    pure a = Parser $ \input -> Just (input, a)
    (Parser p1) <*> (Parser p2) =
        Parser $ \input ->
            p1 input >>= \(input', f) ->
                p2 input' >>= \(input'', a) ->
                    Just (input'', f a)

instance Alternative Parser where
    empty = Parser $ const Nothing
    (Parser p1) <|> (Parser p2) =
        Parser $ \input -> p1 input <|> p2 input

char :: Char -> Parser Char
char c =
    Parser $ \input ->
        case input of
          (x:xs) | x == c -> Just (xs, x)
          _               -> Nothing

eof :: Parser undefined -- use only with (<*)
eof =
    Parser $ \input ->
        case input of
          "" -> Just ("", undefined)
          _  -> Nothing
