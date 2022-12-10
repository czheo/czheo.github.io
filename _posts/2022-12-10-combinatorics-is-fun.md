---
layout: post
title: Combinatorics is Fun
author: czheo
---

I did some fun combinatorial exercises to reach an optimal O(n) solution for [an "easy" level leetcode problem (LeetCode 1588)](https://leetcode.com/problems/sum-of-all-odd-length-subarrays/).

Look at the problem and think for 5 minutes. It is relatively easy to reach this approach: For each element $$a_i$$, if you can find the count of odd-length sub-arrays containing it, denoted as $$n_i$$, the sum of all odd-length sub-arrays will be equal to $$\sum a_i n_i$$. The interesting part is how we can find out $$n_i$$.

## Step 1: visualize all sub-arrays

Let's use a tuple `(i,j)` to denote a sub-array where `i` and `j` are the start and end index.
Then we can plot all sub-arrays of an array with length `L` in the table below.

```
(0,  0)
(0,  1)  (1,  1)
(0,  2)  (1,  2)  (2,  2)
(0,  3)  (1,  3)  (2,  3)  (3,  3)
(0,  4)  (1,  4)  (2,  4)  (3,  4)  (4,  4)
...      ...      ...      ...      ...     ... 
(0,L-1)  (1,L-1)  (2,L-1)  (3,L-1)  (4,L-1) ... (L-1,L-1)
```

## Step 2: visualize all sub-arrays containing a specific element

For an element $$a_i$$, let's mark all sub-arrays containing it in the table below.
For example, those surrounded in the box below are the sub-arrays who contain $$a_1$$.

```
 (0,  0)          sub-arrays containing a1
+----------------+
|(0,  1)  (1,  1)|
|(0,  2)  (1,  2)| (2,  2)
|(0,  3)  (1,  3)| (2,  3)  (3,  3)
|(0,  4)  (1,  4)| (2,  4)  (3,  4)  (4,  4)
|...      ...    | ...      ...      ...     ... 
|(0,L-1)  (1,L-1)| (2,L-1)  (3,L-1)  (4,L-1) ... (L-1,L-1)
+----------------+
```

As another example, below are the sub-arrays who contain $$a_3$$.

```
 (0,  0)
 (0,  1)  (1,  1)
 (0,  2)  (1,  2)  (2,  2)           sub-arrays containing a3
+----------------------------------+
|(0,  3)  (1,  3)  (2,  3)  (3,  3)|
|(0,  4)  (1,  4)  (2,  4)  (3,  4)| (4,  4)
|...      ...      ...      ...    | ...     ... 
|(0,L-1)  (1,L-1)  (2,L-1)  (3,L-1)| (4,L-1) ... (L-1,L-1)
+----------------------------------+ 
```

For generalization, given any $$a_i$$, there exists a rectangular "table", where each "cell" represents a sub-array containing $$a_i$$, illustrated as below.

```
+-------------------------------------+
|(0,  i)  (1,  i)  (2,  3) ... (i,  i)|
|(0,i+1)  (1,i+1)  (2,i+1) ... (i,i+1)|
|...      ...      ...     ... ...    |
|(0,L-1)  (1,L-1)  (2,L-1) ... (i,L-1)|
+-------------------------------------+ 
```

We can see the width of the table is $$(i+1)$$ and the height is $$(L-i)$$ so there are $$(i+1) \times (L-i)$$ sub-arrays in total.

A non-visual proof: For a sub-array starting at $$m$$ and ending at $$n$$, we have $$m \leq i \leq n$$ if $$a_i$$ is in it. Thus, there are $$i + 1$$ choices to pick m in the range of `0...i` and $$L - i$$ choices of n in the range of `i...L-1`.

## Step 3: find out how many sub-arrays in the table have odd lengths

Observation 1: the top-right corner cell `(i, i)` is a sub-array with length = 1 which is odd.

Observation 2: given any cell, its 4 neighbors (top, down, left, right) must have a length with different parity. i.e.

  - If a cell is even length, all 4 neighbors must be odd.
  - If a cell is odd length, all 4 neighbors must be even.

Let's mark odd-length cells with `o` and even-length with `x`.
We obtain a chessboard-like shape and just need to find out **how many `o` are there in the table**.

```
+----------+
|.. x o x o|<--- the top-right cell must be o
|.. o x o x|
|.. x o x o|
|..........|
|..........|
+----------+
```

Observation 3: there are half of the cells are `o` (in most cases).
See examples below.

```
+---+
|x o|
|o x|
+---+
```

```
+-----+
|o x o|
|x o x|
+-----+
```

```
+---+
|x o|
|o x|
|x o|
+---+
```

Observation 4: there is an exception: if the total number of cells is an odd number, there will be one more `o` than `x`.

```
+-----+
|o x o|
|x o x|
|o x o|
+-----+
```

Given all the observations above, we can tell the total number of `o` cells are `(N + 1) // 2`, where `N` is the total number of cells in the table, which we already know in step 2 is $$(i+1)\times(L-i)$$.

## Final solution in Python

```python
class Solution:
    def sumOddLengthSubarrays(self, arr):
        return sum(((i + 1) * (len(arr) - i) + 1) // 2 * n for i, n in enumerate(arr))
```

## Appendix

Some refresh of tricks about division:
In Python `x // y` is a round-down division.
For round-up division, one way is to `import math` and use `math.ceil`.
Another way of rounding up is `(x + y - 1) // y`.
In the exercise above, `(N + 1) // 2` is a special case of this formula.

```python
>>> for x in range(20):
...     print(x, math.ceil(x / 5), (x + 4) // 5)
...
0 0 0
1 1 1
2 1 1
3 1 1
4 1 1
5 1 1
6 2 2
7 2 2
8 2 2
9 2 2
10 2 2
11 3 3
12 3 3
13 3 3
14 3 3
15 3 3
16 4 4
17 4 4
18 4 4
19 4 4
```
