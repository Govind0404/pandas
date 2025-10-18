# Test Setup Documentation

This repository contains the assets to validate a pandas feature request via failing tests and a deterministic runner.

## Files

### 1) Dockerfile (updated)
- Location: `./Dockerfile`
- Purpose: Development/build image based on `public.ecr.aws/x8v8d7g8/mars-base:latest` suitable for building and testing pandas offline after build.

### 2) Test patch
- Location: `./test.patch`
- Purpose: Git patch adding pytest tests under `pandas/tests/groupby/` for a new `GroupBy.weighted_mean` reduction. The tests are designed to fail on base pandas (feature missing) and pass only after implementing the feature.

### 3) Test runner script
- Location: `./test.sh`
- Usage: `./test.sh [base|new]`
- Modes:
  - `base`: runs a stable, existing pandas test that must pass on the base commit
  - `new`: runs the newly added tests that must fail before the feature is implemented

## Usage

1) Build the Docker image
```bash
docker build -t pandas-dev .
```

2) Run the container (interactive shell at `/app`)
```bash
docker run -it pandas-dev
```

3) Apply the tests patch inside the repo
```bash
git apply test.patch
```

4) Run tests
```bash
./test.sh base  # should pass
./test.sh new   # should fail before implementation
```

## Notes
- Tests are pure pytest (no TypeScript/Jest).
- The image installs Python deps during build; the container runs fully offline.
- The patch only touches the test tree and runner script; no production code is modified by the patch.
