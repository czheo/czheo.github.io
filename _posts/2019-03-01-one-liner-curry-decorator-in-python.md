---
layout: post
title: One-liner curry decorator in Python
author: czheo
categories:
  - tech
---

I discovered the following trick.

~~~ py
from functools import partial
curry = lambda f: partial(*[partial] * (f.__code__.co_argcount - 1), f)
~~~

Usage

~~~ py
@curry
def add(x, y, z):
    return x + y + z

print(add(2)(3)(4))
# output = 9
~~~
