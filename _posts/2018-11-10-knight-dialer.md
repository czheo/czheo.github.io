---
layout: post
title: Knight Dialer
author: czheo
categories:
  - code
---

Below is my solution to [Leetcode Problem 935](https://leetcode.com/problems/knight-dialer/description/).
The code is much more concise than any DP solution I have seen so far.
A rough analysis is given here: [link](https://www.dropbox.com/s/8e2q8jp0b5th42t/ZYC001.pdf).

~~~ python
class Solution(object):
    def knightDialer(self, N):
        """
        :type N: int
        :rtype: int
        """
        if N == 1:
            return 10

        n = 1
        a, b, c, d = 4, 2, 2, 1
        while n < N:
            a, b, c, d = b * 2 + c * 2, a, a + d * 2, c
            n += 1

        return (a + b + c + d) % (10 ** 9 + 7)
~~~
