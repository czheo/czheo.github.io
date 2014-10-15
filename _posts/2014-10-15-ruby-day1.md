---
layout: post
title: Ruby - Day 1
author: czheo
---
Interactive Ruby Shell

~~~
irb
~~~

A taste

~~~ ruby
properties = ['object oriented', 'duck typed', 'productive', 'fun']
properties.each {|property| puts "Ruby is #{property}."}  ## => ["object oriented", "duck typed", "productive", "fun"]
~~~

~~~ ruby
puts "hello, world"
language = "Ruby"
puts "hello, #{language}"
~~~

Ruby is object oriented

~~~ ruby
4
4.class  # => Fixnum
(4.0).class  # => Float
4.methods
4 + 3
4.+ 3
4.+(3)

false.class  # => FalseClass
true.class  # => TrueClass
~~~

Condition

~~~ ruby
# if
## block form
if true
  puts "yes"
end
## one line form
puts "yes" if true

# unless = if not
unless false
  puts "yes"
end
puts "yes" unless false

# real world usage
puts x unless x.nil?
~~~

One line loop

~~~ ruby
x = x + 1 while x < 10
x = x - 1 until x == 1
~~~

Every thing but `nil` and `false` evaluate to true

~~~ ruby
!!1 # true

!!0 # true

!!"a random string" # true

!!Object # true

!!nil # false
~~~

~~~ ruby
# and == &&
true and false
# false

# or == ||
true or false
# false


false && this_causes_error # false
false & this_causes_error # error

true || this_causes_error # true
true | this_causes_error # error
~~~

### Self-Study

http://ruby-doc.org/

String substitutes: http://www.ruby-doc.org/core-2.1.3/String.html#method-i-sub

~~~ ruby
# sub(pattern, replacement) → new_str
"hello".sub(/[aeiou]/, '*')  # => "h*llo"
"hello".sub(/([aeiou])/, '<\1>')  # => "h<e>llo"

# sub(pattern, hash) → new_str
ENV["SHELL"]  # => "/bin/bash"
"current shell is SHELL".sub(/[[:upper:]]+/, ENV)  # => "current shell is /bin/bash"

# sub(pattern) {|match| block } → new_str
"hello".sub(/./) {|s| s.ord.to_s + ' '}  # => "104 ello"
"hello".gsub(/./) {|s| s.ord.to_s + ' '}  => "104 101 108 108 111 "
~~~

Regex: http://www.ruby-doc.org/core-2.1.3/Regexp.html

~~~ruby
"hello" =~ /e/  # => 1
/e/ =~ "hello"  # => 1

/e/.match "hello"  # => #<MatchData "e">
"hello".match /e/  # => #<MatchData "e">
~~~

Range: http://www.ruby-doc.org/core-2.1.3/Range.html

~~~ ruby
(1..5).to_a  # => [1, 2, 3, 4, 5]
(1...5).to_a  # => [1, 2, 3, 4]
('a'..'e').to_a  #=> ["a", "b", "c", "d", "e"]
~~~

### Do
find index of a string

~~~ ruby
"Hello, world".index "world"  # => 7
~~~

print 10 times

~~~ ruby
for i in (1..10)
  puts "hello¥n #{i}"
end
~~~

random number

~~~ruby
rand  #=> 0 ~ 1
rand 10 #=> 0 ~ 10
~~~
