# Add GroupBy.weighted_mean to pandas (API-aligned, focused scope)

## Problem Brief
Introduce a first-class weighted mean reduction on pandas GroupBy. Today, users must write ad‑hoc code with `groupby.apply` or `np.average` plus manual alignment. This task adds `weighted_mean` to GroupBy with clear, minimal semantics that match typical pandas reductions.

## Public API (what must exist)
- `SeriesGroupBy.weighted_mean(weights, *, numeric_only=None) -> Series`
- `DataFrameGroupBy.weighted_mean(weights, *, numeric_only=None)` when a single column is selected (e.g., `df.groupby(keys)["v"].weighted_mean(...)`) returns a `Series`.

Notes
- `numeric_only` is accepted for signature compatibility but not used in this task.
- Multi-column DataFrameGroupBy output (returning a DataFrame) is out of scope for this challenge.

## Semantics (what behavior is required)
- Weights may be:
  1) Column name (str) from the original object,
  2) 1D array-like aligned to the original object index,
  3) Series with the same index labels (alignment by index required).
- NA handling: rows where data or weight is NA are ignored (pairwise drop). NA weights contribute 0.
- Zero effective total weight per group produces `NaN` for that group (do not drop the group).
- Result index/order mirrors standard GroupBy behavior (works with MultiIndex and categorical groupers).
- Errors:
  - Length/shape mismatch between values and weights → `ValueError`.
  - Non-numeric data in the reduced values → `TypeError`.

## Test Assumptions (structural constraints, not test logic)
- The above methods are available on pandas `GroupBy` objects.
- Single-column selection returns a `Series`.
- Alignment by index is supported when `weights` is a Series in a different order.
- Exact error message text is not specified; only exception types are validated.

## Out of Scope
- DataFrameGroupBy with multiple selected columns returning a DataFrame.
- `numeric_only` behavior beyond signature compatibility.
- Rolling/expanding/ewm variants; numba engine.

## Example
```python
df = pd.DataFrame({
    "g": ["A", "A", "B", "B"],
    "v": [10.0, 20.0, 5.0, 15.0],
    "w": [1.0, 3.0, 2.0, 2.0],
})
out = df.groupby("g")["v"].weighted_mean(weights="w")
assert out.to_dict() == {"A": 17.5, "B": 10.0}
```
