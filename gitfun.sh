#!/bin/bash

# Usage:
#     ./gitfun.sh

# how to update README.md:
#     rm shattered-*; ./gitfun.sh > README.md


# comes from: https://stackoverflow.com/a/38057371
git-hash-object () { # substitute when the `git` command is not available
  local type=blob
  [ "$1" = "-t" ] && shift && type=$1 && shift
  # depending on eol/autocrlf settings, you may want to substitute CRLFs by LFs
  # by using `perl -pe 's/\r$//g'` instead of `cat` in the next 2 commands
  local size=$(cat $1 | wc -c | sed 's/ .*$//')
  ( echo -en "$type $size\0"; cat "$1" ) | sha1sum | sed 's/ .*$//'
}


run-cmd () {
  echo "> $1"
  eval "$1"
}


echo '# SHA1 has been SHAttered: Is git now broken?'
echo ''
echo 'No. Infos:'
echo ''
echo '* SHAttered https://shattered.it/'
echo '  * Code: https://github.com/cr-marcstevens/sha1collisiondetection'
echo '* "the collision is entirely a non-issue": https://stackoverflow.com/a/9392525'
echo '* https://stackoverflow.com/questions/7225313/how-does-git-compute-file-hashes'
echo ''
echo "## shattered files"
echo ''
echo 'Same SHA1 hash, SHA256 hashes differ:'
echo ''
for i in {1..2}; do
  if [ ! -f shattered-$i.pdf ]; then
    echo '```bash'
    run-cmd "wget --no-verbose  https://shattered.it/static/shattered-$i.pdf  2>&1"
    echo '```'
  else
    echo "shattered-$i.pdf [skip; already exists]"
  fi
done
echo -e '\n```bash'
run-cmd "sha1sum shattered-*.pdf"
echo ''
run-cmd "sha256sum shattered-*.pdf"
echo '```'

echo -e "\n## hashes of git-repos still differ\n"
echo 'To create two git repos with same SHA1 id does not work with the'
echo '`shattered-{1,2}.pdf` files.'
echo ''
for i in {1..2}; do
  echo -e "\n### repo containing shattered-$i.pdf (renamed as shattered.pdf)\n"

  rm -rf gitrepo$i
  mkdir gitrepo$i
  cp shattered-$i.pdf  gitrepo$i/shattered.pdf
  cd gitrepo$i
  git init >/dev/null
  git add shattered.pdf
  git commit -am 'add shattered.pdf' >/dev/null

  echo -e "\nSHA1 ID of HEAD\n"
  echo '```bash'
  run-cmd "git log -1 --pretty='%H'"
  echo '```'

  echo -e "\ngit-hash of shattered.pdf\n"
  echo '```bash'
  run-cmd "cat shattered.pdf | git hash-object --no-filters --stdin"
  echo '```'

  cd ..
done


echo -e "\n## Why do the hashes still differ?\n"
echo ''
echo 'Because git applies a SHA1 not on the file itself but also'
echo 'incorporates its size:'
echo ''
echo '```'
echo 'git-hash(file) := SHA1("blob <file_size>\0<file_content>")'
echo '```'
for i in {1..2}; do
  echo -e "\n### shattered-$i.pdf"

  echo -e '\ncommand `git hash-object`\n'
  echo '```bash'
  run-cmd "cat shattered-$i.pdf | git hash-object --no-filters --stdin"
  # cat shattered-$i.pdf | git hash-object --stdin
  echo '```'

  echo -e '\ngit-hash replacement\n'
  echo '```bash'
  run-cmd "git-hash-object shattered-$i.pdf"
  echo '```'

  echo -e '\n"manually" calculate git-hash\n'
  echo '```bash'
  echo "> size=\$(cat shattered-$i.pdf | wc -c | sed 's/ .*$//')"
  size=$(cat shattered-$i.pdf | wc -c | sed 's/ .*$//')
  echo "> ( echo -en \"blob \$size\0\"; cat shattered-$i.pdf ) | sha1sum | sed 's/ .*$//'"
  ( echo -en \"blob $size\0\"; cat shattered-$i.pdf ) | sha1sum | sed 's/ .*$//'
  echo '```'
done
