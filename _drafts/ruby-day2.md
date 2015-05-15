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
# this is just syntactic sugar
a[-1]  # => "e"
# accessing undefined array elements does not raise an error
a[100]  # => nil
# this is not syntactic sugar. 0..1 is a Range, inclusively
a[1..3] # => ["b", "c", "d"]
# exclusive Range
a[1...3] # => ["b", "c"]
a[1..100] # => ["b", "c", "d", "e"]
~~~

~~~ ruby
# :[] is just a method of Array
[].methods.include?(:[])
# this is equivalent to a[1..3]
a.[] 1..3

a = [1]
a.push 1
# => [1,1]
a.pop
# => 1
~~~

Hash

The keys can be any type of object

~~~ ruby
h = {1=>"a", 2=>"b"}
h = {:string=>"a", :array=>[1,2,3]}
~~~
