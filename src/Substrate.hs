{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Integration smoke-test for the circuits substrate.
--
-- Importing one representative module from each substrate package proves that
-- the whole set compiles and links together.
module Substrate (greenLights) where

import Circuit.Agent (Post, mkPost)
import Circuit.Diff.Circuit qualified as CDD
import Circuit.LLM.GPT ()
import Circuit.Mat (Mat)
import Circuit.Meter (Meter)
import Circuit.PCA ()
import Circuit.Parser (Parser, These, char, runParserIdentity)
import Circuit.ChannelPoly (systemAsProcess)
import Circuit.Process (Process, scan)
import Data.Functor.Identity (Identity)
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import Harpie.Array (Array, array)
import NumHask.Prelude (one)
import NumHask.Space (Point (..))
import Circuit.Stats (ma)

greenLights :: IO ()
greenLights = do
  putStrLn "numhask: green"
  print (one :: Int)
  putStrLn "circuits-diff: green"
  print (Proxy :: Proxy (CDD.Diff Double Double))
  putStrLn "numhask-space: green"
  print (Point 1 2 :: Point Int)
  putStrLn "harpie: green"
  print (array [2, 2] [1, 2, 3, 4] :: Array Int)
  putStrLn "circuits-stats: green"
  print (scan (ma 0.1) [1, 2, 3 :: Double])
  putStrLn "circuits: green"
  print (Proxy :: Proxy (Process Double Double))
  putStrLn "string-diagrams: green"
  print (Proxy :: Proxy (Process Double Double))
  putStrLn "circuits-diff: green"
  print (Proxy :: Proxy (CDD.Diff Double Double))
  putStrLn "circuits-mat: green"
  print (Proxy :: Proxy (Mat Double () ()))
  putStrLn "circuits-parser: green"
  print (runParserIdentity (char 'a' :: Parser Identity String Char Char) "abc" :: These Char String)
  putStrLn "circuits-pca: green"
  putStrLn "circuits-llm: green"
  putStrLn "circuits-meter: green"
  print (Proxy :: Proxy (Meter (->) () ()))
  putStrLn "circuits-agent: green"
  print (mkPost "substrate" ["agent"] "hello" :: Post Text)
