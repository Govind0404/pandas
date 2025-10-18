# Add GroupBy.weighted_mean to pandas (API-aligned feature)

## Problem Brief
Analysts frequently need a weighted mean per group. pandas currently requires ad‑hoc code using `groupby.apply` or manual reindex/alignment with `np.average`. This task introduces a first‑class, API‑aligned reduction: `weighted_mean` on `SeriesGroupBy` and `DataFrameGroupBy`.

Goal: design and implement `GroupBy.weighted_mean` with pandas‑style semantics, including index alignment, NA handling, dtype rules, and performance expectations. The work should integrate with pandas internals (not a standalone helper function) and be covered by comprehensive tests.

## Requirements (acceptance criteria)
Functional API
- Add `SeriesGroupBy.weighted_mean(weights, *, numeric_only=None)` that returns a `Series` with index equal to the group index.
- Add `DataFrameGroupBy.weighted_mean(weights, *, numeric_only=None)` that returns a `Series` if a single column is selected, or a `DataFrame` for multiple columns.
- `weights` may be:
  1) A column name (str) in the original object,
  2) 1D array‑like aligned to the original object index,
  3) A Series indexed like the original object (alignment by index required).
- Length/shape mismatches must raise `ValueError`. Non‑numeric data with non‑NA values must raise `TypeError`.

Semantics
- Default NA policy: skip NA in data or weights. NA weights are treated as 0 contribution.
- Groups whose effective total weight is 0 produce `NaN` (consistent with reductions like `mean` rather than silently dropping groups).
- Result index preserves group order and type (works with MultiIndex groupers and categorical groupers).
- Output dtype follows pandas rules: floating result for numeric inputs, preserves extension dtypes where applicable once converted to float.

Scope/depth
- Support:
  - Single and multiple grouping keys (including MultiIndex results).
  - Alignment when `weights` is provided as a separate Series with a different order but the same index labels.
  - Nullable integer/boolean and float dtypes.
  - `numeric_only` handling consistent with other DataFrameGroupBy reductions.
  - Reasonable vectorization (no Python loops over groups; use block/EA aware ops when possible).

Out of scope for this task
- Rolling/expanding/ewm weighted means.
- numba engine.

## Tests and determinism
The provided tests assert correctness across:
- Basic numeric cases, NA in values and weights.
- Zero total weight → NaN result.
- Index alignment when weights are passed as a misordered Series.
- MultiIndex groups, categorical groupers, and dtype coverage.
- Error cases: length mismatch, non‑numeric values.

All tests are deterministic and unambiguous with clear success criteria.

## Example (intended API shape)
```python
import pandas as pd

df = pd.DataFrame({
    "g": ["A", "A", "B", "B"],
    "v": [10.0, 20.0, 5.0, 15.0],
    "w": [1.0, 3.0, 2.0, 2.0],
})

out = df.groupby("g")["v"].weighted_mean(weights="w")
# A 17.5; B 10.0
assert out.to_dict() == {"A": 17.5, "B": 10.0}
```
