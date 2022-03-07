---
layout: post
title: Java Duck Typing without Reflection
author: czheo
---

Can we implement duck typing in Java without using reflection?

Consider there are 2 classes defined by an external library that is out of our control.

``` java
class Duck {
  void swim() {...}
}

class Whale {
  void swim() {...}
}
```

We cannot do below.

``` java
Stream.of(new Duck(), new Whale()).forEach(obj -> {
  obj.swim(); // Compilation error since obj is of type `Object` which has no swim() method
});
```

Ideally, we want to define a common interface with a `swim()` method, and let `Duck` and `Whale` both implement it. But since this is an external library, we cannot modify the definitions. Instead, we can use a pattern like below to achieve duck typing.

``` java
interface SwimAware {
  static SwimAware coerce(Duck duck) {
    return new SwimAware() {
      @Override
      public void swim() {
        duck.swim();
      }
    };
  }

  static SwimAware coerce(Whale whale) {
    return new SwimAware() {
      @Override
      public void swim() {
        whale.swim();
      }
    };
  }

  void swim();
}
```

Usage of `SwimAware`

``` java
Stream.of(SwimAware.coerce(new Duck()), SwimAware.coerce(new Whale())).forEach(obj -> {
  obj.swim(); // obj is a SwimAware now, which has the swim() method
});
```
