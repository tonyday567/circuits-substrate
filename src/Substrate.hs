{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Integration smoke-test for the circuits substrate.
--
-- Importing one representative module from each substrate package proves that
-- the whole set compiles and links together.
module Substrate (greenLights) where

import Circuit.AD qualified as CAD
import Circuit.Agent (Post (..))
import Circuit.LLM.GPT ()
import Circuit.Mat (Mat)
import Circuit.Meter (Meter)
import Circuit.PCA ()
import Circuit.Parser (Parser, These, char, runParserIdentity)
import Circuit.Poly.Process (systemAsProcess)
import Circuit.Process (Process, scan)
import Data.Functor.Identity (Identity)
import Data.Proxy (Proxy (..))
import Harpie.Array (Array, array)
import Harpie.NumHask ()
import NumHask.Diff qualified as NHD
import NumHask.Prelude (one)
import NumHask.Space (Point (..))
import Process.Stats (ma)

greenLights :: IO ()
greenLights = do
  putStrLn "numhask: green"
  print (one :: Int)
  putStrLn "numhask-diff: green"
  print (Proxy :: Proxy (NHD.Diff Double Double))
  putStrLn "numhask-space: green"
  print (Point 1 2 :: Point Int)
  putStrLn "harpie: green"
  print (array [2, 2] [1, 2, 3, 4] :: Array Int)
  putStrLn "harpie-numhask: green"
  putStrLn "process-stats: green"
  print (scan (ma 0.1) [1, 2, 3 :: Double])
  putStrLn "circuits: green"
  print (Proxy :: Proxy (Process Double Double))
  putStrLn "string-diagrams: green"
  print (Proxy :: Proxy (Process Double Double))
  putStrLn "circuits-ad: green"
  print (Proxy :: Proxy (CAD.Diff Double Double))
  putStrLn "circuits-mat: green"
  print (Proxy :: Proxy (Mat Double () ()))
  putStrLn "circuits-parser: green"
  print (runParserIdentity (char 'a' :: Parser Identity String Char Char) "abc" :: These Char String)
  putStrLn "circuits-pca: green"
  putStrLn "circuits-llm: green"
  putStrLn "circuits-meter: green"
  print (Proxy :: Proxy (Meter (->) () ()))
  putStrLn "circuits-agent: green"
  print (Post "substrate" ["agent"] "hello" :: Post)
