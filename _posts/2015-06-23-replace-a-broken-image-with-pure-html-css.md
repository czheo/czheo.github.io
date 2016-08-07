---
layout: post
title: Replace a broken image with pure HTML/CSS
author: czheo
---

On most browsers, an image that fails to load will show as a broken image icon like this.
<img src="error.img" />

I occasionally heard two of my colleagues talking about how to replace a broken icon with a normal image using Javascript. Most solutions you can find are like below.

~~~ js
document.getElementById("myImg").onerror = function() {
    this.src = "http://images.all-free-download.com/images/graphicthumb/symbols_error_99738.jpg";
}
~~~

There is nothing wrong to do it with Javascript. However this made me wonder about how to do the same with pure HTML/CSS. The first idea I came up with was to use `background-image`. But it turned out a broken image icon will still show at the upper-left corner and there seems to be no easy solution to hide the icon on most browsers.

~~~ css
#myImg {
    width: 200px; height: 200px;
    background-image: url("http://images.all-free-download.com/images/graphicthumb/symbols_error_99738.jpg");
}
~~~

<img src="error.img" style="width: 200px; height: 200px; background-image: url('http://images.all-free-download.com/images/graphicthumb/symbols_error_99738.jpg');">

So I did some research and finally found an interesting solution.

~~~ html
<object data="error.img" type="image/png">
<img src="http://images.all-free-download.com/images/graphicthumb/symbols_error_99738.jpg" />
</object>
~~~

The effect looks as below.

With a broken image:

<object data="error.img">
<img src="http://images.all-free-download.com/images/graphicthumb/symbols_error_99738.jpg" />
</object>

With a good image:

<object data="http://upload.wikimedia.org/wikipedia/commons/1/1b/Square_200x200.png">
<img src="http://images.all-free-download.com/images/graphicthumb/symbols_error_99738.jpg" />
</object>

You can find some further discussions on [Stack Overflow](http://stackoverflow.com/questions/10407236/is-it-valid-to-include-images-with-object-instead-of-img)
