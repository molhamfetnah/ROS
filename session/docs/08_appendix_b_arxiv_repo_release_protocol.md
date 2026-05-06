# Appendix B — ArXiv + Repository Release Protocol

## B1. Pre-release gate
1. All experiments reproducible from clean setup.
2. Figures regenerate from raw outputs.
3. Known limitations explicitly documented.
4. README includes exact replication commands.

## B2. Repository professional structure
1. `src/` algorithms and wrappers
2. `simulations/` environment configs
3. `experiments/` run scripts
4. `results/` generated artifacts policy
5. `tests/` unit + integration + stress
6. `docs/` method, protocol, assumptions, threat model

## B3. ArXiv manuscript synchronization
1. Manuscript references exact commit hash.
2. Each figure maps to script path + output artifact.
3. Benchmark tables map to machine-readable CSV files.
4. Reproducibility note includes compute budget and runtime envelope.

## B4. Release order
1. Freeze code and tag release candidate.
2. Run final reproducibility sweep.
3. Publish repository release.
4. Submit ArXiv with repository link.
5. Publish concise technical announcement.

## B5. Post-release credibility tasks
1. Add issue templates for reproducibility problems.
2. Track external replication attempts.
3. Publish clarifications and fixes transparently.
