---
layout: post
title: One-liner curry decorator in Python
author: czheo
categories:
  - code
---

I discovered the following trick.

~~~ py
from functools import partial
curry = lambda n: partial(*[partial] * n)
~~~

Usage:
~~~ py
@curry(3)
def add(x, y, z):
    return x + y + z

print(add(2)(3)(4))
# output = 9
~~~

A more obfuscated way will be:

~~~ py
from functools import partial
curry = lambda f: partial(*[partial] * f.__code__.co_argcount)(f)
~~~

Usage

~~~ py
@curry
def add(x, y, z):
    return x + y + z

print(add(2)(3)(4))
# output = 9
~~~
