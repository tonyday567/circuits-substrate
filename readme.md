# circuits-substrate

A local integration canary for the circuits substrate. It depends on every
substrate package and runs a single executable, `substrate-green-lights`, that
imports one representative module from each package and prints a green line per
package. If the canary builds, the whole substrate compiles and links together.

```bash
cd ~/haskell/circuits-substrate
cabal build all
cabal run substrate-green-lights
```

## The 25 packages

The substrate is everything under `~/haskell/` — 25 repos. The canary imports
one representative module from each of the 24 siblings plus itself.

| # | package | representative module |
|---|---|---|
| 1 | `numhask` | `NumHask.Prelude` |
| 2 | `numhask-space` | `NumHask.Space` |
| 3 | `harpie` | `Harpie.Array` |
| 4 | `formatn` | `Data.FormatN` |
| 5 | `manyvalued` | `Circuit.Logics` |
| 6 | `circuits` | `Circuit.Process` |
| 7 | `circuits-diff` | `Circuit.Diff.Circuit` |
| 8 | `circuits-mat` | `Circuit.Mat` |
| 9 | `circuits-diagrams` | `Circuit.Poly.StringDiagram` |
| 10 | `circuits-stats` | `Circuit.Stats` |
| 11 | `circuits-parser` | `Circuit.Parser` |
| 12 | `circuits-pca` | `Circuit.PCA` |
| 13 | `circuits-llm` | `Circuit.LLM.GPT` |
| 14 | `circuits-meter` | `Circuit.Meter` |
| 15 | `circuits-agent` | `Circuit.Agent` |
| 16 | `circuits-inference` | `Circuit.Inference.Prob` |
| 17 | `circuits-learn` | `Circuit.Learn.Para` |
| 18 | `circuits-rl` | `Circuit.RL.GridWorld` |
| 19 | `chart-svg` | `Chart` |
| 20 | `markup-parse` | `MarkupParse` |
| 21 | `prettychart` | `Prettychart` |
| 22 | `mnet` | `Net` |
| 23 | `sysl` | `SysL` |
| 24 | `free-agent` | `Free.Agent.Bus` |
| 25 | `circuits-substrate` | `Substrate` (this canary) |

The authoritative dependency graph is `cabal.project` (which packages are in
scope) plus the library `build-depends` in `circuits-substrate.cabal` (which
the canary links against). The `Substrate` module is the smoke test: one
import per package.

## Adjacent external dependencies

One-step-away Hackage packages used by the substrate libraries. These are the
neighbours you are likely to bump into when working in any of the repos.

| package | used by | role |
|---|---|---|
| `profunctors` | `circuits`, `circuits-stats` | categorical plumbing |
| `stm` | `circuits` | channel-level concurrency |
| `adjunctions` | `numhask-space`, `harpie` | representable/functorial arrays |
| `distributive` | `numhask-space`, `harpie` | distributive functors |
| `semigroupoids` | `numhask-space` | semigroupoid instances |
| `first-class-families` | `harpie` | type-level computation |
| `vector` | `harpie`, `numhask-space`, `circuits-stats`, … | boxed/unboxed arrays |
| `vector-algorithms` | `harpie`, `circuits-stats` | sorting vectors |
| `containers` | `numhask`, `numhask-space`, `circuits-stats`, … | maps and sets |
| `text` | `numhask-space`, `circuits-stats`, `circuits-parser`, `circuits-llm` | text values |
| `bytestring` | `circuits-parser`, `circuits-llm` | byte streams |
| `time` | `numhask-space` | time types |
| `hmatrix` | `harpie`, `circuits-pca`, `circuits-llm` | BLAS-backed linear algebra |
| `random` | `harpie`, `circuits-llm` | random generation |
| `mwc-probability` | `numhask-space`, `circuits-stats` | probability distributions |
| `dunning-t-digest` | `numhask-space`, `circuits-stats` | approximate quantiles (t-digest) |
| `logict` | `circuits-parser` | backtracking parser logic |
| `mtl` | `circuits-parser` | monad transformers |
| `these` | `circuits-parser` | `These` result type |
| `process` | `circuits-parser` | spawning external processes |
| `prettyprinter` | `harpie`, `circuits-mat` | pretty-printing arrays |
| `primitive` | `circuits-stats` | primitive arrays / ST |
| `deepseq` | `circuits-parser`, `circuits-llm`, `circuits-meter` | strict NFData |
| `transformers` | `circuits-diff` | standard transformers |
| `ad-delcont` | `circuits-diff` | AD oracle reference |
| `clock` | `circuits-meter` | timing measurements |
| `optparse-applicative` | `circuits-meter` | CLI for observe executables |
| `tasty-bench` | `circuits-parser` | benchmarking harness |

## Verification and observation: the square

The substrate uses two complementary treatments for code that needs more than a
doctest:

```
        axiomatize  ↔  verify
              ↕
        machine     ↔  observe
```

| direction | treatment | stanza | main file | purpose |
|---|---|---|---|---|
| outward | **axiomatic verification** | `xyzzy-verify` | `app/verify.hs` | closed-form oracles, typeclass laws, exact checks |
| inward | **machine observation** | `xyzzy-observe` (separate package) | `app/observe.hs` | measurement, diagnosis, tolerance specification |

### Default: doctests as oracles

- In-source `>>>` examples are the first-class oracles.
- `cabal-docspec` runs them as the default hold-out verification and
development hook.
- A package should not have a `test/` directory just to wrap doctests.

### When you need more than a doctest

- **Axiomatic oracles** that need multiple dependencies or closed-form checks
  become an executable stanza `xyzzy-verify` with main file `app/verify.hs`.
- **Machine observation** that needs measurement dependencies becomes a
  *separate* package `xyzzy-observe` with main file `app/observe.hs`, so the
  core library stays clean for Stackage and does not carry measurement tools.
- Ask whether you are stating a **law** (`verify.hs`) or a **tolerance**
  (`observe.hs`). Explain either way.

### What is not in this pattern

- Benchmark comparisons against other libraries are measurement plumbing, not
  `observe.hs`. They live in separate benchmark or measurement scripts.
- `test-suite` stanzas that only shell out to `cabal-docspec` are glue, not a
  suite; remove them and call `cabal-docspec` directly in CI.
- No parallel test frameworks (tasty, Hspec, QuickCheck) without a written
  exception.

## External dependencies

| dependency | consumers | reason |
|---|---|---|
| `dunning-t-digest` | `numhask-space`, `circuits-stats` | maintained t-digest implementation with `base < 5`; replaced the unmaintained `tdigest` package |
