{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE RecordWildCards #-}

-- | Generate a dashboard markdown file for the circuits substrate.
-- Usage: cabal run trystero-dashboard [-- --output dashboard.md]
module Main where

import Options.Applicative
import Prelude

data Status = CI_Hackage | CI_Only | None deriving (Eq)

data Options = Options
  { optOutput :: String,
    optUser :: String
  }

options :: Parser Options
options = do
  optOutput <-
    strOption
      ( long "output"
          <> short 'o'
          <> metavar "FILE"
          <> value "dashboard.md"
          <> showDefault
          <> help "Output markdown file"
      )
  optUser <-
    strOption
      ( long "user"
          <> short 'u'
          <> metavar "USER"
          <> value "tonyday567"
          <> showDefault
          <> help "GitHub user or organisation"
      )
  pure Options {..}

opts :: ParserInfo Options
opts = info (options <**> helper) (fullDesc <> progDesc "Generate trystero dashboard")

ciBadge :: String -> String -> String
ciBadge user repo =
  "[![build](https://github.com/"
    <> user
    <> "/"
    <> repo
    <> "/actions/workflows/haskell-ci.yml/badge.svg)](https://github.com/"
    <> user
    <> "/"
    <> repo
    <> "/actions/workflows/haskell-ci.yml)"

hackageBadge :: String -> String
hackageBadge repo =
  "[![hackage](https://img.shields.io/hackage/v/"
    <> repo
    <> ".svg?label=%22%22)](https://hackage.haskell.org/package/"
    <> repo
    <> ")"

stackageBadge :: String -> String
stackageBadge repo =
  "[![stackage lts](https://www.stackage.org/package/"
    <> repo
    <> "/badge/lts)](https://www.stackage.org/package/"
    <> repo
    <> ") [![stackage nightly](https://www.stackage.org/package/"
    <> repo
    <> "/badge/nightly)](https://www.stackage.org/package/"
    <> repo
    <> ")"

stackagePackages :: [String]
stackagePackages =
  [ "numhask",
    "numhask-space",
    "harpie",
    "chart-svg",
    "formatn",
    "markup-parse",
    "prettychart"
  ]

row :: String -> (String, Status) -> String
row user (repo, s) =
  let (ci, hkg, stk) = (s == CI_Hackage || s == CI_Only, s == CI_Hackage, repo `elem` stackagePackages)
   in "|["
        <> repo
        <> "](https://github.com/"
        <> user
        <> "/"
        <> repo
        <> ") |"
        <> "[![Issues](https://img.shields.io/github/issues/"
        <> user
        <> "/"
        <> repo
        <> "?label=%22%22)](https://github.com/"
        <> user
        <> "/"
        <> repo
        <> "/issues) |"
        <> "[![PRs](https://img.shields.io/github/issues-pr/"
        <> user
        <> "/"
        <> repo
        <> "?label=%22%22)](https://github.com/"
        <> user
        <> "/"
        <> repo
        <> "/pulls) |"
        <> (if ci then ciBadge user repo else "")
        <> " |"
        <> (if hkg then hackageBadge repo else "")
        <> " |"
        <> (if stk then stackageBadge repo else "")
        <> "|\n"

dashHeader :: String
dashHeader =
  "# trystero dashboard\n\n"
    <> "CI status, open issues/PRs, Hackage and Stackage presence for the 27 substrate packages.\n\n"
    <> "| Name | Issues | PRs | Status | Hackage | Stackage |\n"
    <> "| ---- | ------ | --- | ------ | ------- | -------- |\n"

repos :: [(String, Status)]
repos =
  [ ("numhask", CI_Hackage),
    ("numhask-space", CI_Hackage),
    ("harpie", CI_Hackage),
    ("circuits", CI_Hackage),
    ("circuits-agent", CI_Only),
    ("circuits-chu", CI_Only),
    ("circuits-diagrams", CI_Only),
    ("circuits-diff", CI_Only),
    ("circuits-inference", CI_Only),
    ("circuits-learn", CI_Only),
    ("circuits-llm", CI_Only),
    ("circuits-log", CI_Only),
    ("circuits-mat", CI_Only),
    ("circuits-meter", CI_Only),
    ("circuits-parser", CI_Only),
    ("circuits-pca", CI_Only),
    ("circuits-rl", CI_Only),
    ("circuits-stats", CI_Only),
    ("trystero", CI_Only),
    ("chart-svg", CI_Hackage),
    ("formatn", CI_Hackage),
    ("manyvalued", CI_Only),
    ("markup-parse", CI_Hackage),
    ("mnet", CI_Only),
    ("prettychart", CI_Hackage),
    ("sysl", CI_Only),
    ("free-agent", CI_Only)
  ]

main :: IO ()
main = do
  Options {..} <- execParser opts
  writeFile optOutput $
    dashHeader <> mconcat (row optUser <$> repos)
