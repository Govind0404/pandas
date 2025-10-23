#!/bin/bash
set -euo pipefail

echo "Running tests..."
python -V

if [ ! -f .pandas_built ]; then
  echo "Building pandas extensions (editable install)..."
  python -m pip install --no-build-isolation --no-deps -e .
  touch .pandas_built
fi

case "$1" in
 base)
    # Run a couple of stable tests that should pass at base commit
    pytest -q \
      pandas/tests/frame/test_constructors.py::TestDataFrameConstructors::test_construct_from_list_of_datetimes \
      pandas/tests/series/methods/test_nunique.py::test_nunique
    ;;
 new)
   # Run only the newly added tests (should fail before implementation)
   pytest -q \
     pandas/tests/groupby/test_weighted_mean.py::TestGroupByWeightedMean::test_dataframe_groupby_multi_column_raises_notimplemented \
     pandas/tests/groupby/test_weighted_mean.py::TestGroupByWeightedMean::test_non_numeric_weights_raises \
     pandas/tests/groupby/test_weighted_mean.py::TestGroupByWeightedMean::test_all_zero_weights_return_nan_per_group \
     pandas/tests/groupby/test_weighted_mean.py::TestGroupByWeightedMean::test_missing_weights_column_raises_keyerror \
     pandas/tests/groupby/test_weighted_mean.py::TestGroupByWeightedMean::test_result_index_preserves_groupby_order
   ;;
 *)
   echo "Usage: ./test.sh {base|new}"
   exit 1
   ;;
esac
