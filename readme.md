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

## CI

11 of the 25 repos carry CI — the published libraries and the ones soon to be:
chart-svg, circuits, circuits-meter, circuits-parser, circuits-stats, formatn,
harpie, markup-parse, numhask, numhask-space, prettychart. The other 14 (the
unpublished experiments and this canary) have none yet.

### Default workflow

`numhask-space` is the reference template (`.github/workflows/haskell-ci.yml`):

- `hlint` — `fail-on: warning`.
- `ormolu` — `haskell-actions/run-ormolu@v17`, pinned to 0.8.1.1.
- `build` — GHC 9.14 / 9.12 / 9.10 on ubuntu, plus 9.14 on windows and macos:
  configure, `cabal build all`, `cabal check`, then `cabal-docspec` on
  9.14/ubuntu.

### Variations from default

| repo | variation | why |
|---|---|---|
| `harpie` | extra `hmatrix bridge` job | manual `flag hmatrix` switches in the BLAS/LAPACK compute backend; the job installs `libblas-dev liblapack-dev` and builds with `--flag hmatrix` |
| `circuits-meter` | `Run benchmarks` step (`cabal run perf-bench`) in place of docspec | the measurement package ships showcase executables |
| `markup-parse` | ormolu stubbed; `--enable-tests` | carries a `test-suite markup-parse-diff` (tasty-golden); ormolu disabled over a version mismatch |
| `formatn`, `numhask` | ormolu stubbed | same ormolu version-mismatch history |
| `chart-svg` | no `cabal-docspec` step | never added |
| `circuits-parser` | lint-only workflow (`name: lint`, no build) | minimal workflow, never grown to the full template |

### Known failure causes

- **sibling `../` refs in committed `cabal.project`** — the build matrix fails on
  CI's shallow clone because sibling dirs don't exist on the runner. The
  convention is a self-contained `cabal.project` with sibling deps moved to the
  gitignored `cabal.project.local`.
- **lint debt** — commits landing without running `ormolu`/`hlint` first.
- **doctest errors** — stale `>>>` examples across the substrate (missing
  imports, renamed constructors), being hunted down as of this snapshot.

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
