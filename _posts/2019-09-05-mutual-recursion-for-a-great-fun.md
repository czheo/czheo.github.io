---
layout: post
title: Mutual recursion for a great fun
author: czheo
---
A random question popped up in my mind tonight: can the following program be written without using `while True`?

~~~ py
def f():
    while True:
        yield 0

for i in f():
    print(i) # print an infinite sequence of 0s
~~~

One solution I came up with is to use mutual recusion.

~~~ py
def f():
    yield 0
    yield from g()

def g():
    yield from f()
    
for i in f():
    print(i)
~~~
