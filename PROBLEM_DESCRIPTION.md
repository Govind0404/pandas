# Add GroupBy.weighted_mean to pandas

## 1) Problem Brief
Provide a first-class `GroupBy.weighted_mean` reduction. Today users rely on ad hoc `apply`/`np.average` patterns. The goal is a clear method that handles alignment, NA policy, and edge cases like zero weights.

## 2) Agent Instructions
Implement a weighted-mean reduction on pandas GroupBy:
- Public surface
  - `SeriesGroupBy.weighted_mean(weights, *, numeric_only=None) -> Series`
  - `DataFrameGroupBy.weighted_mean(weights, *, numeric_only=None)` supported only when a single value column is selected (returns a Series).
  - `numeric_only` is accepted for API compatibility; no special handling is required.
- Accepted weights
  1) `str` column name from the original object
  2) 1D array-like, same length as the grouped object
  3) `Series` aligned by index to the grouped object (order may differ)
- NA policy
  - Pairwise drop: drop rows where either value or weight is NA.
- Zero-weight groups
  - If the effective total weight is 0, return `NaN` for that group.
- Ordering and index
  - Follow standard GroupBy conventions (MultiIndex, categorical order preserved).
- Exceptions (exact types)
  - `TypeError`: non-numeric data reduced; non-numeric weights
  - `ValueError`: length/shape mismatch for array-like weights (raise with the
    message `"weights must be the same length as the data"`)
  - `KeyError`: `weights` given as a missing column name
- Multi-column DataFrameGroupBy
  - Calling `weighted_mean` on a DataFrameGroupBy with multiple selected columns MUST raise `NotImplementedError`.

## 3) Test Assumptions
Structural constraints only (implementation details not prescribed):
- Methods named exactly:
  - `SeriesGroupBy.weighted_mean(weights, *, numeric_only=None)`
  - `DataFrameGroupBy.weighted_mean(weights, *, numeric_only=None)`
- Single-column selection returns a `Series` named with the original column.
- Tests assert exception types; the ValueError check also validates the
  message `"weights must be the same length as the data"`.

## 4) Setup and Execution
- Docker image builds all Python dependencies and installs pandas (editable) during build; container runs offline.
- `test.patch` adds tests under `pandas/tests/groupby/` and a `test.sh` runner
  with `base` and `new` modes (the `new` mode runs only newly added tests).
- `solution.patch` contains only implementation changes.
