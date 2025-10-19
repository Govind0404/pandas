# Add GroupBy.weighted_mean to pandas

## 1) Problem Brief
Users frequently need a weighted mean per group. Today this requires ad‑hoc patterns (e.g., `groupby.apply` or `np.average` plus manual alignment). Add a first‑class reduction, `weighted_mean`, on pandas GroupBy that behaves like other pandas reductions and handles index alignment and missing data consistently. Success means users can call a clear, documented method to compute per‑group weighted means without custom plumbing.

## 2) Agent Instructions
Implement a weighted-mean reduction available on pandas GroupBy with the following behavior:
- Public surface
  - `SeriesGroupBy.weighted_mean(weights, *, numeric_only=None) -> Series`.
  - `DataFrameGroupBy.weighted_mean(weights, *, numeric_only=None)` when a single column is selected (e.g., `df.groupby(keys)["v"].weighted_mean(...)`) returns a `Series`.
  - The `numeric_only` parameter is accepted for signature compatibility but does not need special handling for this task.
- Weights may be one of:
  1) A column name (str) from the original object,
  2) A 1D array-like aligned to the original object’s index,
  3) A Series with the same index labels (must align by index; order may differ).
- NA handling: Pairwise drop — exclude any row where either the value or the weight is NA (i.e., NA weights are treated as missing and excluded).
- Zero-weight groups: If the effective total weight of a group is 0, the result for that group is `NaN` (do not drop the group).
- Index/order: Follow standard GroupBy conventions (works with MultiIndex and categorical groupers; preserves categorical order).
- Errors: Length/shape mismatches between values and weights raise `ValueError`. Reducing non‑numeric data raises `TypeError`.

This task focuses on single-column reductions that return a Series. Multi‑column DataFrameGroupBy output (returning a DataFrame) is explicitly out of scope.

## 3) Test Assumptions (minimal structural constraints)
These are the only structural elements the tests rely on; they do not prescribe implementation details:
- Methods named exactly:
  - `SeriesGroupBy.weighted_mean(weights, *, numeric_only=None)`
  - `DataFrameGroupBy.weighted_mean(weights, *, numeric_only=None)`
- When a single column is selected, the return type is `Series` with the original column name.
- Passing `weights` as a misordered Series with matching index labels aligns by index.
- Exception types are validated (TypeError/ValueError); exact error message text is not required.

No alternate function names or module paths are assumed by the tests.
