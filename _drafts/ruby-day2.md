---
layout: post
title: Ruby - Day 2
author: czheo
---
Unlike Java and C#, you don't have to build a class to define a function.

The function will return the value of the last expression.

~~~ruby
def tell_the_truth
    true
end
~~~

Array

~~~ruby
a = ["a", "b", "c", "d", "e"]
a[-1]  # => "e"   # this is syntactic sugar
a[100]  # => nil
a[1..3] # => ["b", "c", "d"]    # this is not syntactic sugar
a[1...3] # => ["b", "c"]
a[1..100] # => ["b", "c", "d", "e"]

# :[] is a method of Array
[].methods.include?(:[])
a.[] 1..3  # a[1..3]

a = [1]
a.push 1 # => [1,1]
a.pop # => 1
a # => [1]
~~~

Hash

The keys can be any type of object

~~~ ruby
h = {1=>"a", 2=>"b"}
h = {:string=>"a", :array=>[1,2,3]}
~~~
