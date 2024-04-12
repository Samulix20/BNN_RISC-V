#!/bin/bash

rm -rf build
mkdir -p build/work

cd src
src_files=$(find -name "*.vhd")
hdr_files=$(echo "$src_files" | grep -E "pkg")
src_files=$(echo "$src_files" | grep -vE "pkg")

err=$(ghdl -a -Wc,-O3 -Wa,-O3 --workdir=../build/work --std=08 $hdr_files $src_files 2>&1)
if [[ $? != 0 ]]
then
    echo "$err"
    exit 1
fi

err=$(ghdl -e -Wc,-O3 -Wa,-O3 --workdir=../build/work --ieee=synopsys -fexplicit --std=08 "test" 2>&1)
if [[ $? != 0 ]]
then
    echo "$err"
    exit 1
fi

if [[ $1 ]]
then
    rv_id="_$1"
fi

mv "test" "../build/riscv$rv_id"
rm e~*.o
cd ..
rm -rf build/work