---
layout: post
title: A Lemma in Graph Theory
author: czheo
---

When solving a puzzle, I found the following lemma:
**the parity of the number of even-degree vertices toggles after removing a vertex.**
In other words, if the number of even-degree vertices is odd, it will become even;
if the number of even-degree vertices is even, it will become odd.
Proof is given in [my note](https://www.dropbox.com/s/up385wnihmvo0p1/ZYC006.pdf).

Update (2019-01-07): A simpler proof was revealed by a colleague:

We know that $$\vert V_o \vert + \vert V_e \vert = \vert V \vert$$,
and $$\vert V_o \vert$$ must be even.
Then, if $$\vert V \vert$$ is odd, $$\vert V_e \vert$$ must be odd.
After removing a vertex, $$\vert V' \vert$$ becomes even and $$\vert V_e' \vert$$ must be even.
If $$\vert V \vert$$ is even, similar reasoning also holds.
(End of Proof)

Another way of rephrasing this lemma will be: **the parity of the number of even-degree vertices is the same as the the parity of the number of vertices.**