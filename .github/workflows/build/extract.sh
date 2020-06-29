#!/bin/bash
set -e

echo "==> Verifying sums..."
sha256sum -c sum.txt

echo "==> Extracting source archive..."
tar -xf src.tar.zst -C /home/build

echo "==> Deleting source archive..."
rm src.tar.zst
