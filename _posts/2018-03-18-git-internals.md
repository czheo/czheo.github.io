---
layout: post
title: Git Internals
author: czheo
categories:
  - tech
---

We will create a git repository named `git_internals` from scratch with minimal use of conventional git commands. I use git version `2.8.1`.

## Git init
First, we create an empty folder.

~~~ bash
$ mkdir git_internals
$ cd git_internals/
~~~

Surely, it's not a git repo yet so `git status` blames us unhappily.

~~~ bash
$ git status
fatal: Not a git repository (or any of the parent directories): .git
~~~

All the magics behind the scene of git happen in the `.git/` folder in your repository. So we create the `.git/` folder.

~~~ bash
$ mkdir .git/
$ git status
fatal: Not a git repository (or any of the parent directories): .git
~~~

But it seems the `.git/` folder alone is not enough. Let's add some other things.

~~~ bash
$ mkdir .git/objects
$ mkdir .git/refs
$ echo "ref: refs/heads/master" > .git/HEAD
~~~

The `.git/` folder now looks like the following and `git status` is happy with us.

~~~ bash
$ tree .git/
.git/
├── HEAD
├── objects
└── refs
$ git status
On branch master

Initial commit

nothing to commit (create/copy files and use "git add" to track)
~~~

So far, we have initialized a git repo.
This is basically what `git init` does for us under the scene.

But wait! What is the `objects/`, `refs/` and `HEAD` in the `.git/` folder?
Hold on for a minute and we will explore them later along the way.
But what I can tell you for now is that `HEAD` stores the information about the branch you are currently on.

You can do the following and find out `git status` tells you are on branch `forked` now.

~~~ bash
$ echo "ref: refs/heads/forked" > .git/HEAD
$ git status
On branch forked

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	hello.txt

nothing added to commit but untracked files present (use "git add" to track)

# But let's go back to branch master
$ echo "ref: refs/heads/master" > .git/HEAD
~~~

## Git add
Let's create a file in our **workspace**. When I say "workspace", I literally mean in the `git_internals` folder.

~~~ bash
$ echo "hello git" > hello.txt
$ git status
On branch master

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	hello.txt

nothing added to commit but untracked files present (use "git add" to track)
~~~

Unsurprisingly, `git status` knows that we have an untracked file named `hello.txt`.
We'd like to add this file in to the git **staging area**, by which I mean to do `git add hello.txt`.

~~~ bash
$ git add hello.txt
$ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   hello.txt
$ tree .git
.git
├── HEAD
├── index
├── objects
│   └── 8d
│       └── 0e41234f24b6da002d962a26c2495ea16a425f
└── refs
~~~

Now our `hello.txt` is **staged**. Two new files are created under `.git/`:

- The `index` file, as its name indicates, stores the index of what files are staged.
- The `objects/8d/0e41234f24b6da002d962a26c2495ea16a425f` file stores the actual data of the staged file `hello.txt`.

If we delete the index file, git will lose the information about what we just staged.

~~~ bash
# temporarily delete index
$ mv .git/index .git/index_
$ git status
On branch master

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	hello.txt

nothing added to commit but untracked files present (use "git add" to track)

# recover index
$ mv .git/index_ .git/index
~~~

By the way, we can use `git ls-files` to inspect what files are tracked in the index.
The output shows `mode`, `SHA1 hash`, `stage number` and `name` of the file.
We are not going to dig into the stage number, but I can briefly tell you that it's used to distinguish conflicted files when merging and it's usually set to be `0` if there's no conflict.

~~~
$ git ls-files --stage
100644 8d0e41234f24b6da002d962a26c2495ea16a425f 0	hello.txt
~~~

Here, we notice the SHA1 value happens to be in the path of the object file `objects/8d/0e41234f24b6da002d962a26c2495ea16a425f`. The first two hex digits of SHA1 are used as the bucket names to avoid too many files being created in the same folder and degrading the performance of the underlying file system.

We also have another command provided by git: `git hash-object`, which reads a file and generates a SHA1 hash based on its contents and some metadata.

~~~ bash
$ git hash-object hello.txt
8d0e41234f24b6da002d962a26c2495ea16a425f
~~~

Let's write some Python code to demonstrate how this SHA1 is generated.

~~~ python
# hash_blob.py
import sys, hashlib

s = sys.stdin.read()
# FORMAT: "blob <length of content><NULL><content>"
blob = 'blob %d\x00%s' % (len(s), s)
print(hashlib.sha1(blob.encode('utf8')).hexdigest())
~~~

Our Python script reads content from the stdin and generates the same SHA1 hash as `git hash-object`.

~~~ bash
$ python hash_blob.py < hello.txt
8d0e41234f24b6da002d962a26c2495ea16a425f
~~~

What happens behind the scene is that git creates a **blob object** which has the format `"blob <length of content><NULL><content>"`. (`<NULL>` represents the bytes of `\x00`).
This blob object is then stored as a compressed file.
We revise our Python script to perform the compression as well.

~~~ python
# hash_blob.py
import sys, hashlib, zlib

s = sys.stdin.read()
# FORMAT: "blob <length of content><NULL><content>"
blob = 'blob %d\x00%s' % (len(s), s)
print(hashlib.sha1(blob.encode('utf8')).hexdigest())
print(zlib.compress(blob.encode('utf8'), level=1))
~~~

We quickly check that our script can generate the identical output as git does.

~~~ bash
$ python hash_blob.py < hello.txt
8d0e41234f24b6da002d962a26c2495ea16a425f
b'x\x01K\xca\xc9OR04`\xc8H\xcd\xc9\xc9WH\xcf,\xe1\x02\x006A\x05\xa3'

$ cat .git/objects/8d/0e41234f24b6da002d962a26c2495ea16a425f \
| python -c 'import sys; print(sys.stdin.buffer.read())'
b'x\x01K\xca\xc9OR04`\xc8H\xcd\xc9\xc9WH\xcf,\xe1\x02\x006A\x05\xa3'
~~~

Let's create a new file `hello2.txt` which has the same content as `hello.txt` and stage it.

~~~ bash
$ cp hello.txt hello2.txt
$ git add hello2.txt
$ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   hello.txt
	new file:   hello2.txt
~~~

Now if we look at `.git`, we find something interesting: there's only one blob object.
But if you dig into the index, we see two files pointing to the same SHA1 hash.
Interestingly, git uses the hash value to deduplicate objects with same contents.

~~~ bash
$ tree .git
.git
├── HEAD
├── index
├── objects
│   └── 8d
│       └── 0e41234f24b6da002d962a26c2495ea16a425f
└── refs
$ git ls-files -s
100644 8d0e41234f24b6da002d962a26c2495ea16a425f 0	hello.txt
100644 8d0e41234f24b6da002d962a26c2495ea16a425f 0	hello2.txt
~~~

Lessons learnt:

- `git add` creates an `index` file and blob objects.
- SHA1 is used as the unique ID of the object for deduplication.

## Git commit

Finally, we are able to commit our changes. A lot of things happen in `.git/`.

~~~ bash
$ git commit -m "My first commit"
$ tree .git
.git
├── COMMIT_EDITMSG
├── HEAD
├── index
├── logs
│   ├── HEAD
│   └── refs
│       └── heads
│           └── master
├── objects
│   ├── 43
│   │   └── 3869c28e75b1b9648b7c9cce7d8f1622d930eb
│   ├── 58
│   │   └── 452a586535b0e636d91e4d08007f93e70a6591
│   └── 8d
│       └── 0e41234f24b6da002d962a26c2495ea16a425f
└── refs
    └── heads
        └── master
~~~

We find there is an object in `objects/` whose SHA1 happens to be the hash value of our first commit `433869c28e75b1b9648b7c9cce7d8f1622d930eb`.
Actually, a git commit is also stored as an object, namely **commit object**.

~~~ bash
$ git log
commit 433869c28e75b1b9648b7c9cce7d8f1622d930eb
Author: czheo <czheo1987@gmail.com>
Date:   Sun Mar 18 19:40:58 2018 -0700

    My first commit
~~~

Same as the blob objects, we can decompress the commit object for investigation.

~~~ bash
$ cat .git/objects/43/3869c28e75b1b9648b7c9cce7d8f1622d930eb \
| python -c "import sys, zlib, hashlib; \
c = zlib.decompress(sys.stdin.buffer.read()); \
print('hash =', hashlib.sha1(c).hexdigest()); print(); \
print(c); print(); \
print(c.decode('utf8'))"
hash = 433869c28e75b1b9648b7c9cce7d8f1622d930eb

b'commit 170\x00tree 58452a586535b0e636d91e4d08007f93e70a6591\nauthor czheo <czheo1987@gmail.com> 1521427258 -0700\ncommitter czheo <czheo1987@gmail.com> 1521427258 -0700\n\nMy first commit\n'

commit 170tree 58452a586535b0e636d91e4d08007f93e70a6591
author czheo <czheo1987@gmail.com> 1521427258 -0700
committer czheo <czheo1987@gmail.com> 1521427258 -0700

My first commit
~~~

The format of a commit object looks as below.
The first field `commit` shows the type of the object.
The second field stores the length of the payload.
Seperated by `<NULL>` (`b"\x00"`), the rest are the payload of the commit object.
Most information looks quite straightforward!
If you are wondering the difference between author and committer, [here](https://stackoverflow.com/questions/18750808/difference-between-author-and-committer-in-git) has the answer.

~~~
commit <length><NULL>
tree <hash of tree>\n
author <name> <email> <timestamp> <mode>\n
committer <name> <email> <timestamp> <mode>\n
\n
<commit message>\n
~~~

Here we notice that the commit object points to a "tree", whose hash value is `58452a586535b0e636d91e4d08007f93e70a6591`, which also can be found in the `objects/` folder.
Actually, it's the SHA1 hash of a **tree object**.
Git uses tree objects to present the identical concept of folders.

~~~ bash
$ cat .git/objects/58/452a586535b0e636d91e4d08007f93e70a6591 \
| python -c "import sys, zlib, hashlib; \
c = zlib.decompress(sys.stdin.buffer.read()); \
print('hash =', hashlib.sha1(c).hexdigest()); print(); \
print(c)"
hash = 58452a586535b0e636d91e4d08007f93e70a6591

b'tree 75\x00100644 hello.txt\x00\x8d\x0eA#O$\xb6\xda\x00-\x96*&\xc2I^\xa1jB_100644 hello2.txt\x00\x8d\x0eA#O$\xb6\xda\x00-\x96*&\xc2I^\xa1jB_'
~~~

A tree object stores a list of blob/tree objects.
The format of a commit object looks as below.

~~~
tree <length><NULL>
<mode> <file name><NULL><object hash>
<mode> <file name><NULL><object hash>
...
~~~

The blob hashes are stored as binary. You are able to find the sequence of `8d0e41234f24b6da002d962a26c2495ea16a425f` if you look at the binary form.

~~~ bash
$ cat .git/objects/58/452a586535b0e636d91e4d08007f93e70a6591 | python -c "import sys, zlib; \
sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read()))" | xxd

00000000: 7472 6565 2037 3500 3130 3036 3434 2068  tree 75.100644 h
00000010: 656c 6c6f 2e74 7874 008d 0e41 234f 24b6  ello.txt...A#O$.
                                ^^^^^^^^^^^^^^^^^
00000020: da00 2d96 2a26 c249 5ea1 6a42 5f31 3030  ..-.*&.I^.jB_100
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
00000030: 3634 3420 6865 6c6c 6f32 2e74 7874 008d  644 hello2.txt..
                                               ^^
00000040: 0e41 234f 24b6 da00 2d96 2a26 c249 5ea1  .A#O$...-.*&.I^.
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
00000050: 6a42 5f                                  jB_
          ^^^^^^^
~~~

**As we have seen, git has three types of objects: `blob`, `commit` and `tree`.**
They are compressed and stored under `.git/objects/` with their SHA1 hashes in the paths.

Remember what is in the file `.git/HEAD`? Yes, it's `ref: refs/heads/master`, which means it's a reference to the path `refs/heads/master`.
If we take a look at the file `.git/refs/heads/master`, it's a plain text file having a SHA1 hash pointing to our previously discorvered commit object.

~~~ bash
$ cat .git/refs/heads/master
433869c28e75b1b9648b7c9cce7d8f1622d930eb
~~~

Under `.git/refs/heads/`, git maintains the most recent commit (the head) for each branch.
We can manually create a new branch by create a new file under `.git/refs/heads/`.
After executing the commands below, the head of `newbr` should points to the same commit as `master`.

~~~ bash
$ git branch
* master
$ cp .git/refs/heads/master .git/refs/heads/newbr
$ git branch
* master
  newbr
~~~

Remember how we switched branch at the beginning of this post?
Even without the head of the branch being created, we can switch to a branch.
Git determines which branch you are currently on by looking at the `.git/HEAD` file.

~~~ bash
$ echo "ref: refs/heads/newbr" > .git/HEAD
$ git branch
  master
* newbr
~~~

There's something we do not cover in this post: `.git/logs/`.
If you are familiar with the `git reflog` command, it should be not difficult to figure out what this folder does by your own.

## Commit objects are linked lists

Let's create a second commit.

~~~ bash
$ echo "hello again" >> hello.txt
$ git commit -am "My second commit"
[master c9cb777] My second commit
 1 file changed, 1 insertion(+)
$ git log
commit c9cb777b785095f1d61ba213cbe95a2191f1b530
Author: czheo <czheo1987@gmail.com>
Date:   Sun Mar 18 21:52:11 2018 -0700

    My second commit

commit 433869c28e75b1b9648b7c9cce7d8f1622d930eb
Author: czheo <czheo1987@gmail.com>
Date:   Sun Mar 18 19:40:58 2018 -0700

    My first commit
~~~

Three new objects are created under `.git/objects/`:

- `c9cb777b785095f1d61ba213cbe95a2191f1b530`
- `78d0dae4323facf43ec1abb2974dc6aed63b65d7`
- `8ecb1fca678b22a883ceaa0655c0a104b8812b80`

~~~ bash
$ tree .git
.git
├── COMMIT_EDITMSG
├── HEAD
├── index
├── logs
│   ├── HEAD
│   └── refs
│       └── heads
│           └── master
├── objects
│   ├── 43
│   │   └── 3869c28e75b1b9648b7c9cce7d8f1622d930eb
│   ├── 58
│   │   └── 452a586535b0e636d91e4d08007f93e70a6591
│   ├── 78
│   │   └── d0dae4323facf43ec1abb2974dc6aed63b65d7
│   ├── 8d
│   │   └── 0e41234f24b6da002d962a26c2495ea16a425f
│   ├── 8e
│   │   └── cb1fca678b22a883ceaa0655c0a104b8812b80
│   └── c9
│       └── cb777b785095f1d61ba213cbe95a2191f1b530
└── refs
    └── heads
        ├── master
        └── newbr
~~~


Git has provided us another convenient command `git cat-file`.
Given a hash, this command parses the object in `.git/objects/` and pretty prints out the payload, which is similar to what we have done in our Python scripts.

~~~ bash
# explore the commit object
$ git cat-file -t c9cb777b785095f1d61ba213cbe95a2191f1b530
commit
$ git cat-file -p c9cb777b785095f1d61ba213cbe95a2191f1b530
tree 78d0dae4323facf43ec1abb2974dc6aed63b65d7
parent 433869c28e75b1b9648b7c9cce7d8f1622d930eb
author czheo <czheo1987@gmail.com> 1521435131 -0700
committer czheo <czheo1987@gmail.com> 1521435131 -0700

My second commit

# explore the tree object
$ git cat-file -t 78d0dae4323facf43ec1abb2974dc6aed63b65d7
tree
$ git cat-file -p 78d0dae4323facf43ec1abb2974dc6aed63b65d7
100644 blob 8ecb1fca678b22a883ceaa0655c0a104b8812b80	hello.txt
100644 blob 8d0e41234f24b6da002d962a26c2495ea16a425f	hello2.txt

# explore the blob object
$ git cat-file -t 8ecb1fca678b22a883ceaa0655c0a104b8812b80
blob
$ git cat-file -p 8ecb1fca678b22a883ceaa0655c0a104b8812b80
hello git
hello again
~~~

Notice that the commit object has a new record about its `parent` whose value is the SHA1 of the previous commit object.
Because our first commit does not have a previous commit, there is no `parent` record.
We can image that `git log` can simply follow along the linked list of commit objects and print out the history.

~~~ bash
$ git cat-file -p 433869c28e75b1b9648b7c9cce7d8f1622d930eb
tree 58452a586535b0e636d91e4d08007f93e70a6591
author czheo <czheo1987@gmail.com> 1521427258 -0700
committer czheo <czheo1987@gmail.com> 1521427258 -0700

My first commit
~~~

Furthermore, notice git stores the new file `hello.txt` in `8ecb1fca678b22a883ceaa0655c0a104b8812b80` as its whole, instead of the change diff.

## Git tag is "cheating"

When we create a tag in git, it creates a new file under `.git/refs/tags/mytag`.

~~~ bash
$ git tag mytag
$ tree .git
.git
...
├── objects
│   ├── 43
│   │   └── 3869c28e75b1b9648b7c9cce7d8f1622d930eb
│   ├── 58
│   │   └── 452a586535b0e636d91e4d08007f93e70a6591
│   ├── 78
│   │   └── d0dae4323facf43ec1abb2974dc6aed63b65d7
│   ├── 8d
│   │   └── 0e41234f24b6da002d962a26c2495ea16a425f
│   ├── 8e
│   │   └── cb1fca678b22a883ceaa0655c0a104b8812b80
│   └── c9
│       └── cb777b785095f1d61ba213cbe95a2191f1b530
└── refs
    ├── heads
    │   ├── master
    │   └── newbr
    └── tags
        └── mytag
~~~

If we look at it, it's the same as files in `.git/refs/heads/`.

~~~ bash
$ cat .git/refs/tags/mytag
c9cb777b785095f1d61ba213cbe95a2191f1b530
~~~

Therefore, we can tell git branches and tags have little difference internally, although they seem to be quite different from the user's perspective.
Both of them are merely pointers to some commit objects.

The git command API makes tags appear immutable to the users, unlike branches. However, we are smart enough to mutate tags now.

~~~ bash
$ git show mytag
commit c9cb777b785095f1d61ba213cbe95a2191f1b530
...
$ echo "433869c28e75b1b9648b7c9cce7d8f1622d930eb" > .git/refs/tags/mytag
$ git show mytag
commit 433869c28e75b1b9648b7c9cce7d8f1622d930eb
...
~~~
