# Algorithm research and validation

[简体中文](Algorithms.zh-CN.md) · [Home](../README.en-US.md)

Reviewed on 2026-09-28. Forward-model accuracy, numerical inversion and regional applicability are separate concerns.

## Implementations reviewed

| Implementation | Approach | Decision for this project |
| --- | --- | --- |
| [Original TQLocationConverter](https://github.com/TinyQ/TQLocationConverter/blob/2b472086e46afca952c77cb342bd40f72201c5b4/TQLocationConverter.m) | Four forward evaluations per inverse step; axis-aligned containment selects a quadrant; sum-of-axis threshold `1e-5` degrees | Retain forward constants and polygon, replace unreliable quadrant selection |
| [wandergis/coordtransform](https://github.com/wandergis/coordtransform/blob/606c6f3b57b6f1d60458793fea39928d2b11b637/index.js) | One-step inverse; matching `6378245` and BD `xPi` formulas; rectangular region test | Use independent forward outputs as fixtures; iterate the inverse to reduce residual |
| [googollee/eviltransform, Swift](https://github.com/googollee/eviltransform/blob/03ba58d92dfda57f8a1635f3805483c8fc10bd77/swift/LocationTransform.swift) | Both a one-step inverse and a bisection inverse, with documented speed/accuracy tradeoffs | Make tradeoffs explicit, without replacing this project's forward model |
| [Baidu's official iOS conversions](https://lbsyun.baidu.com/docs/ios?title=iossdk%2Fguide%2Ftool%2Fcoordinate) | Provider-supported conversion capabilities and applicability rules | Validate against the official SDK/API when strict provider agreement is required |

Open-source implementations are not identical models. The reviewed eviltransform Swift revision uses `6378137` and `π` in its BD sine terms, while this project and the referenced coordtransform use `π × 3000 / 180`. Matching function names do not make them interchangeable or turn any one library into an official accuracy reference. No external runtime dependency or implementation code was incorporated; the new implementation uses this project's existing formulas, with fixture provenance retained.

## Why replace the old inverse?

The old algorithm uses axis-aligned rectangles between forward-transformed points to choose a quadrant. Latitude and longitude perturbations are coupled, so transformed regions are not necessarily those rectangles. Once it chooses the wrong region, shrinking the interval cannot recover. Reaching the iteration cap returns a midpoint without reporting non-convergence.

The original Objective‑C conversion functions reproduced this case:

```text
WGS-84 input (latitude, longitude): 35.25, 114.25
Original forward GCJ-02: 35.249540255704204, 114.255859407090739
Original inverse WGS-84: 35.251493380238543, 114.250000031625078
Round-trip error: approximately 166.06 meters
```

For the macOS check, only the unused UIKit/polygon section was removed and the conflicting `pi` symbol renamed; conversion mathematics and search logic were unchanged. An explicit regression test now covers this point. Expanded non-grid sampling found an approximately 270.95-meter maximum error in the old inverse, as shown below.

## Current method

For forward conversion `f(x) = x + d(x)` and target `y`, solve `f(x) = y`:

```text
r = f(x) - y
Return x if max(|r.latitude|, |r.longitude|) ≤ 1e-9 degrees
Otherwise update x = x - r and check again
```

This is fixed-point/residual iteration. The offset changes slowly in the intended region, so it typically takes few iterations. Each check evaluates the forward formula once. The solver performs at most 24 checks, reports `nonConvergent` at the limit, and validates each intermediate result. BD‑09LL inversion starts with the original approximate inverse and applies the same refinement.

Newton's method could use a Jacobian, at the cost of derivative computation, singularity handling and maintenance. The original `sqrt(abs(x))` term is also non-differentiable at longitude 105°. Residual iteration passes neighborhood and broad sampling tests without that added complexity. It is not guaranteed to converge for every globally valid coordinate, hence the explicit failure path.

## Reproducible benchmark

Run:

```sh
swift run -c release ConversionBenchmark
```

See [Benchmarks/main.swift](../Benchmarks/main.swift). All three inverses share this project's forward model to isolate solver differences. The old search is ported from this repository; the one-step approximation is `2y - f(y)`. This does not benchmark external libraries as complete packages.

The sample set consists of 4,088 points inside the polygon from a 0.5° grid, plus 4,459 inside points from 10,000 candidates generated with seed `0x5451434F`: **8,547 points** in total. Non-grid samples cover different trigonometric phases. Each original is transformed forward, then inverted. Haversine distance with mean Earth radius 6,371,008.8 meters measures differences. Timings are the median of five warmed runs; region filtering and input generation are excluded.

One run on 2026-09-28, Apple arm64, macOS 27.0, Swift 6.4, Release build:

| Inverse | Maximum round-trip error | Maximum forward residual | Median for 8,547 points | Points above 1 meter |
| --- | ---: | ---: | ---: | ---: |
| One-step approximation | 4.022000 m | 4.044891 m | 1.303 ms | 1,670 |
| Original quadrant search | 270.949795 m | 270.522473 m | 27.683 ms | 36 |
| Residual iteration | 0.000139 m | 0.000139 m | 2.054 ms | 0 |

Residual iteration was approximately 13.5 times faster than the old solver in this run. Timing depends on hardware, compiler, build configuration and load; the ratio is not a universal guarantee. Deterministic grids and pseudorandom samples do not prove correctness for all possible inputs.

## Accuracy and applicability limits

- These values measure **numerical round trips within one community approximation model**, not geographic truth, GPS errors or official map-provider accuracy. `1e-9` degrees is a stopping criterion, not a promise of submillimeter map accuracy.
- The forward formulas and constants preserve the original project. Improving real-world agreement requires documented provider/survey reference points, not just a smaller inverse tolerance.
- The 58-vertex polygon preserves the historical region heuristic. It is not an official geographic boundary, legal determination or provider coverage guarantee.
- Passing outside points through introduces a discontinuity and ambiguity near polygon edges. Select `.unrestricted` explicitly when applicability is known; more detailed boundary data alone cannot eliminate the ambiguity.
- The default policy checks the input once for all directions. Do not infer an SDK's output system from a broad statement about a region; consult its configuration and documentation.

Validation includes independent forward fixtures, six-direction grid round trips, seeded non-grid samples, the longitude-105 neighborhood, polygon edges, legacy regressions, invalid input, concurrency and language parity. No official service credentials or surveyed ground-truth controls were used.
