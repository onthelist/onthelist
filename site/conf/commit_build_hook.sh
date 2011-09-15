#!/bin/bash

echo a
if git branch | grep \* | grep -q master
then
  echo b
  cd site/conf
  echo c
  ./build.sh
  echo d
fi
