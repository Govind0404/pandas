#!/bin/bash
set -e

case "$1" in
  base)
    # Run existing tests - should pass at base commit
    pytest pandas/tests/frame/test_constructors.py::TestDataFrameConstructors::test_construct_from_list_of_datetimes
    ;;
  new)
    # Run newly added tests - should fail before solution
    pytest pandas/tests/frame/test_new_functionality.py
    ;;
  *)
    echo "Usage: ./test.sh {base|new}"
    exit 1
    ;;
esac
