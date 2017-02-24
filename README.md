# SHA1 has been SHAttered: Is git now broken?

No. Infos:

* SHAttered https://shattered.it/
  * Code: https://github.com/cr-marcstevens/sha1collisiondetection
* "the collision is entirely a non-issue": https://stackoverflow.com/a/9392525
* https://stackoverflow.com/questions/7225313/how-does-git-compute-file-hashes
## shattered files

Same SHA1 hash, SHA256 hash differs.

```bash
> wget --no-verbose  https://shattered.it/static/shattered-1.pdf  2>&1
2017-02-24 15:21:09 URL:https://shattered.it/static/shattered-1.pdf [422435/422435] -> "shattered-1.pdf" [1]
```
```bash
> wget --no-verbose  https://shattered.it/static/shattered-2.pdf  2>&1
2017-02-24 15:21:09 URL:https://shattered.it/static/shattered-2.pdf [422435/422435] -> "shattered-2.pdf" [1]
```

```bash
> sha1sum shattered-*.pdf
38762cf7f55934b34d179ae6a4c80cadccbb7f0a  shattered-1.pdf
38762cf7f55934b34d179ae6a4c80cadccbb7f0a  shattered-2.pdf

> sha256sum shattered-*.pdf
2bb787a73e37352f92383abe7e2902936d1059ad9f1ba6daaa9c1e58ee6970d0  shattered-1.pdf
d4488775d29bdef7993367d541064dbdda50d383f89f0aa13a6ff2e0894ba5ff  shattered-2.pdf
```

## hashes of git-repos still differ

To create two git repos with same SHA1 id does not work with the
`shattered-{1,2}.pdf` files.


### repo containing shattered-1.pdf (renamed as shattered.pdf)


SHA1 ID of HEAD

```bash
> git log -1 --pretty='%H'
978a8ec8de67c5f49060fafccb391ed99c7dd299
```

git-hash of shattered.pdf

```bash
> cat shattered.pdf | git hash-object --no-filters --stdin
ba9aaa145ccd24ef760cf31c74d8f7ca1a2e47b0
```

### repo containing shattered-2.pdf (renamed as shattered.pdf)


SHA1 ID of HEAD

```bash
> git log -1 --pretty='%H'
f28fd08028b48f0c8b4e059d97ae464e94531e12
```

git-hash of shattered.pdf

```bash
> cat shattered.pdf | git hash-object --no-filters --stdin
b621eeccd5c7edac9b7dcba35a8d5afd075e24f2
```

## Why do the hashes still differ?


Because git applies a SHA1 not on the file itself but also
incorporates its size:

```
git-hash(file) := SHA1("blob &lt;file_size&gt;\0&lt;file_content&gt;")
```

### shattered-1.pdf

command `git hash-object`

```bash
> cat shattered-1.pdf | git hash-object --no-filters --stdin
ba9aaa145ccd24ef760cf31c74d8f7ca1a2e47b0
```

git-hash replacement

```bash
> git-hash-object shattered-1.pdf
ba9aaa145ccd24ef760cf31c74d8f7ca1a2e47b0
```

"manually" calculate git-hash

```bash
> size=$(cat shattered-1.pdf | wc -c | sed 's/ .*$//')
> ( echo -en "blob $size\0"; cat shattered-1.pdf ) | sha1sum | sed 's/ .*$//'
e4b0e97670916603ea6df1ce16ae0984c4ecade1
```

### shattered-2.pdf

command `git hash-object`

```bash
> cat shattered-2.pdf | git hash-object --no-filters --stdin
b621eeccd5c7edac9b7dcba35a8d5afd075e24f2
```

git-hash replacement

```bash
> git-hash-object shattered-2.pdf
b621eeccd5c7edac9b7dcba35a8d5afd075e24f2
```

"manually" calculate git-hash

```bash
> size=$(cat shattered-2.pdf | wc -c | sed 's/ .*$//')
> ( echo -en "blob $size\0"; cat shattered-2.pdf ) | sha1sum | sed 's/ .*$//'
55e9cd7a2c3e479f86982fe99a71084cd9ffcc3a
```
