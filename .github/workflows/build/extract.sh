#!/bin/bash

echo "==> Resulting sha256sum of src/ archive"
sha256sum src.tar.zst

echo "==> Extracting src archive..."
tar -xf src.tar.zst -C /home/build

echo "==> Deleting src archive..."
rm src.tar.zst
