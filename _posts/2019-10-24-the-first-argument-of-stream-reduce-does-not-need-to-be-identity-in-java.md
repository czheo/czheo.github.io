---
layout: post
title: The first argument of Stream::reduce does not need to be an identity in Java
author: czheo
categories:
    - tech
---

[The official documentation of Java](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html#reduce-T-java.util.function.BinaryOperator-) claims that the first argument of `T Stream::reduce(T identity, BinaryOperator<T> accumulator)` must be an identity.

> The identity value must be an identity for the accumulator function. This means that for all t, accumulator.apply(identity, t) is equal to t. The accumulator function must be an associative function.

`Stream::reduce` works almost identically to `foldl` in Haskell.
In Haskell, you can use `foldl` as below.

~~~ haskell
> foldl (+) 0 [1, 2, 3]
6
> foldl (+) 10 [1, 2, 3]
16
~~~

As we see, it is not required that the initial value (the second argument) of `foldl` be an identity in Haskell (For the addition operation, `0` is the identity but `10` is not).
Actually, you can even do the same in Java.

~~~ java
> Arrays.asList(1,2,3).stream().reduce(0, (a, b) -> a + b)
6
> Arrays.asList(1,2,3).stream().reduce(10, (a, b) -> a + b)
16
~~~

However, according to the Java doc, the second use case is violating the contract although the result is the same as that of `foldl`.

So why is identity required by the `reduce` in Java?
In fact, the Java doc also writes:

> Performs a reduction on the elements of this stream, using the provided identity value and an associative accumulation function, and returns the reduced value ... but is not constrained to execute sequentially.

It implies that the requirement of the identity and associativity must be related to parallelism.

The actual problem occurs when you want to use "parallel stream". For example, the following code gives 36 as result on my machine instead of 16.

~~~ java
> Arrays.asList(1,2,3).stream().parallel().reduce(10, (a, b) -> a + b)
36
~~~

Then, I found a similar question on StackOverflow, and
[one of the answers](https://stackoverflow.com/a/51290673/1061751) gives a plausible explanation.
The main reason of this behavior seems because Java will assign the initial value to each parallelized reduce job.
Given my previous example with input `[1, 2, 3]`, 3 threads were started, each of which was assigned with 10 as the initial value, performing the following computation in parallel.

1. `(10, 1) -> 10 + 1`
2. `(10, 2) -> 10 + 2`
3. `(10, 3) -> 10 + 3`

After all jobs finished, the final result was summed up to be the wrong answer 36, unfortunately.

Here is the point I want to make: is it really necessary that the initial value must be an identity to allow `reduce` to be executed in parallel?
I strongly believe not, and the associativity of `BinaryOperator` alone should be enough to enable parallelism.

Given an expression `A op B op C op D` where `op` is the binary operator, associativity guarantees that its evaluation is equivalent to `(A op B) op (C op D)`, such that we would be able to evaluate `A op B` and `C op D` in parallel and combine their results afterward.
The only reason I can think of why Java requires identity here is that the language developers wanted to simplify the implementation and keep all sub jobs symmetric.
Otherwise, they may have had to differentiate parallelized jobs with/without initial values.

My gut feeling tells me that there must exist a simple implementation that does not require the initial value to be an identity.
So I tried to write a "parallel reduce" `pareduce` function in Haskell as a proof of concept (with my limited Haskell proficiency).

~~~ haskell
import Control.Parallel

partitionSize = 100

pareduce :: (a -> a -> a) -> a -> [a] -> a
pareduce f n xs = pareduce1 f (n:xs)

pareduce1 :: (a -> a -> a) -> [a] -> a
pareduce1 f xs = case tail of [] -> headRes
                              _  -> headRes `par` f headRes tailRes
                  where head = take partitionSize xs
                        tail = drop partitionSize xs
                        headRes = foldl1 f head
                        tailRes = pareduce1 f tail
~~~

~~~ haskell
> pareduce (+) 100 []
100
> pareduce (+) 10 [1..100]
5060
> foldl (+) 10 [1..100]
5060
~~~

Some premature benchmarks show `pareduce` runs around 5 times faster than `foldl` on my machine to sum up `[1..100000000]`.
