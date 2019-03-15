#!/bin/bash
as -g -o $1.o $1.s
gcc -o $1 $1.o
./$1;
