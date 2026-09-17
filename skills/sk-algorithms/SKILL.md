---
name: sk-algorithms
description: Solve coding-interview and competitive programming problems by deriving the required complexity from the input constraints, matching the problem to a known pattern, and checking edge cases before running anything. Use when practising interview problems, working through a competitive programming task, or preparing to explain an approach out loud under time pressure.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Algorithm problems

This is for interview and contest problems, where the constraints are given and the target is a
specific complexity. For making production code faster, use the performance skill instead — the
method there is measurement, not derivation.

## 1. Read the constraints first

The input bound tells you the answer's shape before you have thought about the problem. This is
the single highest-value habit, because it eliminates most approaches immediately:

| n up to | Intended complexity |
|---|---|
| 10-12 | O(n!) — permutations |
| 20-25 | O(2ⁿ) — subsets, bitmask DP |
| 100-500 | O(n³) — Floyd-Warshall, interval DP |
| 2,000-5,000 | O(n²) — pairwise, most DP tables |
| 10⁵-10⁶ | O(n log n) — sort, heap, binary search, one pass with a structure |
| 10⁷-10⁸ | O(n) — single pass, counting |
| 10¹⁸ | O(log n) — binary search on the answer, matrix power, maths |

Also read: the value range (does it overflow 32 bits?), whether values can be negative or zero,
whether duplicates are allowed, and whether the input is already sorted. Each of these changes
which algorithms are legal.

## 2. State the brute force

Say the obvious solution and its complexity out loud, even when it is too slow. It proves you
understand the problem, it gives you a correct reference to test against, and the optimisation
usually appears as "this inner loop recomputes something".

Then name the specific waste: recomputation, rescanning, a sort you are doing repeatedly, or a
search that could be a lookup.

## 3. Match the pattern

| Signal in the problem | Try |
|---|---|
| Sorted array, or pairs summing to a target | Two pointers, binary search |
| Contiguous subarray or substring | Sliding window, prefix sums |
| "K largest / smallest / most frequent" | Heap of size k, or quickselect |
| "Next greater / smaller element" | Monotonic stack |
| Overlapping subproblems, optimal substructure | Dynamic programming |
| Choices that never need revisiting | Greedy — but prove the exchange argument |
| Shortest path, unweighted | BFS |
| Shortest path, weighted non-negative | Dijkstra |
| Connectivity, grouping, cycle detection | Union-find |
| Prefix matching, dictionary of words | Trie |
| Range query with updates | Segment tree, Fenwick tree |
| "Minimum maximum" or "maximum minimum" | Binary search on the answer |
| Tree with a question about every node | One DFS returning a tuple upward |
| Permutations, combinations, "all ways" | Backtracking with pruning |
| Intervals | Sort by start or end, then sweep |

For dynamic programming, define the state in one sentence before writing any code: what does
`dp[i][j]` mean. Most DP failures are an underspecified state, not a wrong transition.

For greedy, be suspicious. If you cannot argue why the locally best choice is globally safe, it
is probably wrong on a case you have not thought of — and a wrong greedy passes the examples far
more often than a wrong DP.

## 4. Check the edges before running

Walk the algorithm by hand on the smallest cases. This costs a minute and catches most of what
a submission would fail on:

- Empty input, and a single element.
- All elements identical; all elements distinct.
- Already sorted, and reverse sorted.
- Negatives, zero, and the maximum value — check whether the accumulator overflows.
- The target being absent, the first element, and the last element.
- For a window or two pointers: the window of size one, and the window covering everything.
- For recursion: the depth at maximum n, against the stack limit.

Then hand-trace one non-trivial example and compare against the expected output before you run
anything.

## 5. Say the complexity

State time and space before you write code, and state them again after — they sometimes differ
from the plan. If space is the constraint, check whether a rolling array replaces the DP table,
or whether you can sort in place.

## Communicating under pressure

Restate the problem in your own words and confirm the constraints before starting. A clarifying
question about duplicates or the empty case is worth more than five minutes of code against the
wrong specification.

Think out loud, and say which pattern you are reaching for and why. An interviewer is evaluating
the derivation, not the recall — a candidate who reasons from the constraint to the complexity to
the pattern is doing the thing the job requires.

When stuck, go back to the brute force and ask what it recomputes. That is where the optimisation
is, nearly every time.
