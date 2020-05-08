# Brainfuck in Haskell!

> It is a truth universally acknowledged, that a single programmer in possession of a GitHub account must be in want of a Brainfuck interpreter repo. - Albert Einstein

Reads from stdin, cat a file into it (see below).

Tested on hello world, nothing more complicated (yet?). No promises.

Many thanks to [Tsoding](https://www.youtube.com/channel/UCEbYhDd6c6vngsF5PQpFVWg), who got me big into Haskell and made an excellent video on [JSON parsing](https://www.youtube.com/watch?v=N9RUqGYuGfw) to which my parsing minilibrary is indebted.

```
$ cat helloworld.bf | runhaskell Main.hs
Hello World!
Memory 0 0 72 100 ->87<- 33 10
```
