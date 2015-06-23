---
layout: post
title: Replace a broken image with pure HTML/CSS
author: czheo
---

On most browsers, a broken image icon will show up when failing to load the image. For example, 
<img src="error.img" />

Today I occasionally heard two of my colleagues talking about replacing a broken image with Javascript. Most solutions you can find on the web are something like below.

~~~ js
document.getElementById("myImg").onerror = function() {
    this.src = "http://www.computerweekly.com/blogs/cwdn/2011/01/25/Human%20error.png";
}
~~~

It is fine to do it with Javascript. However I just wondered about how to do this with pure HTML/CSS. The first idea I came up with was by using `background-image`. But it turned out a broken image icon will show on the upper-left corner and there seems to have no solution to hide the icon on most browsers.

~~~ css
#myImg {
    width: 200px; height: 200px;
    background-image: url("http://www.computerweekly.com/blogs/cwdn/2011/01/25/Human%20error.png");
}
~~~

<img src="error.img" style="width: 200px; height: 200px; background-image: url('http://www.computerweekly.com/blogs/cwdn/2011/01/25/Human%20error.png');">

So I did some research and finally found an interesting solution.

~~~ html
<object data="error.img" type="image/png">
<img src="http://www.computerweekly.com/blogs/cwdn/2011/01/25/Human%20error.png" />
</object>
~~~

The effect looks as below.

With a broken image:

<object data="error.img">
<img src="http://www.computerweekly.com/blogs/cwdn/2011/01/25/Human%20error.png" />
</object>

With a good image:

<object data="http://upload.wikimedia.org/wikipedia/commons/1/1b/Square_200x200.png">
<img src="http://www.computerweekly.com/blogs/cwdn/2011/01/25/Human%20error.png" />
</object>

You can find some further discussino on [stackoverflow](http://stackoverflow.com/questions/10407236/is-it-valid-to-include-images-with-object-instead-of-img)
