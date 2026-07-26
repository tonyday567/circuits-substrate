# ChangeLog for substrate

## 0.1.0.0 — 2026-07-25

- Initial integration canary depending on all 13 substrate packages.
- `Substrate.greenLights` imports one representative module per package.
- `substrate-green-lights` executable prints a green line per package.
- `cabal.project` no longer needs `allow-newer: tdigest:base`; `numhask-space`
  and `process-stats` now depend on `dunning-t-digest` instead of the
  unmaintained `tdigest` package.
