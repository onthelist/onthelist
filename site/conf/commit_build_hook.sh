#!/bin/bash

cd site/conf

if git branch | grep \* | grep -q master ; then
  ./build.sh
fi
