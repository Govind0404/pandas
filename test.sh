#!/bin/bash
set -euo pipefail

case "$1" in
  base)
    # Run an existing, stable test that should pass at base commit
    pytest -q pandas/tests/frame/test_constructors.py::TestDataFrameConstructors::test_construct_from_list_of_datetimes
    ;;
  new)
    # Run the newly added tests that should fail before implementation
    pytest -q pandas/tests/groupby/test_weighted_mean.py
    ;;
  *)
    echo "Usage: ./test.sh {base|new}"
    exit 1
    ;;
esac
