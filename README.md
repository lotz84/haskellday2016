Haskell Day 2016: Spock Example
===============================

[Haskell Day 2016](http://connpass.com/event/37892/)で発表した [Introduction to Web Development with Spock](http://qiita.com/lotz/items/e2c6765e65d7eb692ee2) の中で作成したSpockのExampleコードです.

Install & Execution
-------------------

予めMySQL に`login_sample`というDatabaseを作って`migration.sql`を使用してテーブルを作成しておいて下さい。

```sh
$ stack build
$ stack exec app
```

