---
layout: post
title: Humbled by Fork
author: czheo
---

Luckily, I have never had to use `fork()` in my everyday work.
Otherwise, I guess I would produce 10x more bugs.
Here is an example why I think so.

In a nutshell, `fork()` creates a child process who copies the parent's current status, including the instruction pointer, data/stack/heap space and etc.

Here's a short example.

```c
// test.c
#include <stdio.h>
#include <unistd.h>

int main() {
  int x = 42;
  if (fork() == 0) {
    printf("child pid = %d, forked by %d\n", getpid(), getppid());
    printf("x in child = %d\n", x);
  } else {
    printf("parent pid: %d\n", getpid());
    printf("x in parent = %d\n", x);
  }
  sleep(1);
}

```

The output of the above problem will be something like this.

```
> ./test
parent pid: 47557
x in parent = 42
child pid = 47558, forked by 47557
x in child = 42
```

Notice that `x` is copied from the parent's to the child's memory space after fork.

Here is a brain teaser.
Can you predict how many lines the following program outputs?

```c
// test.c
#include <stdio.h>
#include <unistd.h>

int main() {
  for (int i = 0; i < 2; i++) {
    if (fork() == 0) {
      printf("iteration %d: child pid = %d, forked by %d\n", i, getpid(), getppid());
    } else {
      printf("iteration %d: parent pid: %d\n", i, getpid());
    }
  }
  sleep(1);
}
```

If you run it in terminal, you will find something like below.

``` shell
> ./test
```

```
iteration 0: parent pid: 48102
iteration 1: parent pid: 48102
iteration 0: child pid = 48103, forked by 48102
iteration 1: child pid = 48104, forked by 48102
iteration 1: parent pid: 48103
iteration 1: child pid = 48105, forked by 48103
```

Here is what happened.

1. When `fork()` is called in iteration 0, parent process 48102 (line 1) will create a child 48103 (line 3).
2. Since the full process status is copied, 48102 and 48103 will each increment `i` and continue the loop. So you will see
    1. 48102 creates a child 48104 in iteration 1, where the parent 48102 outputs line 2 and the child 48104 outputs line 4.
    2. Similarly, the child 48103 created during iteration 0 will create its own child 48105 in iteration 1, which then print line 5 and line 6 correspondingly.

Here is an illustration of the parent-child relations of all processes.

- 48102: root process
    - 48103: created in iteration 0
        - 48105: created in iteration 1
    - 48104: created in iteration 1

Now is the most interesting part.
Can you predict the output of below?

```
> ./test | wc -l
```

You may think `wc -l` will just print the count of lines which should be 6, but surprisingly the output is 8. What the hell is happening now?

Here is a clearer picture.

```shell
> ./test > test.output
> cat test.output
```

```
iteration 0: parent pid: 48230
iteration 1: child pid = 48232, forked by 48230
iteration 0: child pid = 48231, forked by 48230
iteration 1: child pid = 48233, forked by 48231
iteration 0: child pid = 48231, forked by 48230
iteration 1: parent pid: 48231
iteration 0: parent pid: 48230
iteration 1: parent pid: 48230
```

The output file will also contain 8 lines, if you redirect the program output.
Remember that the child will copy the parent's memory space.
What has caused this behavior is that the child has copied the `stdout` buffer of the parent, just like the `x` variable we saw before, but somehow more implicitly.

What is buffer?
You may think of it as just a limited size in-memory array that holds the characters before writing to `stdout`.
To reduce the syscalls and IO operations, instead of writing to `stdout` every time there is a character, the buffer will hold the characters up for a while until it reallyreally needs flushed out to `stdout`.

There is 2 modes of buffering: line buffering and full buffering.

- Line buffering will flush every time when there is a newline character. Terminal uses this mode, which is what we observed when running `./test` directly.
- Full buffering will flush when the buffer reaches its size limit, which is what we observed when piping to `wc -l` or redirecting to a file.

In the later case, when the parent process calls `printf(...)` in iteration 0, the characters will be held in the buffer without flushing.
When `fork()` is called during iteration 1, the buffer array is copied to the child as it is.
So when the child prints, the line will be appended to the buffer and eventually get flushed containing the output previously printed by the parent.

Here is the detailed sequence of events producing `test.output`.
1. After the first `fork()`, the parent process 48230 buffer will print `iteration 0: parent pid: 48230\n` and hold it in its buffer.
The child process 48231 will print `iteration 0: child pid = 48231, forked by 48230\n` and hold it in its own buffer.
2. After the second `fork()`, child 48232 will be created by 48230, which copies 48230's buffer first and prints `iteration 1: child pid = 48232, forked by 48230\n`. At this point, 48232's buffer contains `iteration 0: parent pid: 48230\niteration 1: child pid = 48232, forked by 48230\n`. At the end of this process, the buffer is flushed and produces line 1 and line 2 as we see in `test.output`.
3. Similarly, line 3 and line 4 are produced by process 48233, where line 3 has been copied from its parent process 48231.
4. Line 5 and 6 get flushed at the end of process 48231, while line 7 and 8 are flushed at the end of process 48230.

As another experiment, if you add `fflush(stdout);` after each `printf(...);`, the output file will have 6 lines just like printing directly in the terminal.

Imagining what other data that we can accidently copy during fork that we are fully unaware of and the side effects they can possibly cause, I'm so humbled now.
