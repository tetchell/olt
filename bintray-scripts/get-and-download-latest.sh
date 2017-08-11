#!/usr/bin/env bash

latest=$(python get-latest.py $1 $2 $3)
latest_success=$?
echo "Latest version of $3 is $latest"

if [ $latest_success -ne 0 ]; then
    echo "Running get-latest.py failed. Check the output for details."
    exit 1
fi

python download-package.py $1 $2 $3 $latest

if [ $? -ne 0 ]; then
    echo "Running download-package.py failed. Check the output for details."
    exit 1
fi

echo "Retrieval of $3 version $latest succeeded."
