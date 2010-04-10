#!/bin/bash

# extractor -- embed/extract tar.gz into script.sh
#
# Użycie:
#        cat extractor.sh source.tar.gz > install.bin

echo "Extracting file ..."

# licznik ile linii pliku odciąć
COUNT=$(awk '/^__SOURCE__/ { print NR + 1}' "$0")
# obcięcie nagłówka i binarka do potoku | rozpakowanie
tail -n+$COUNT "$0" | tar -xz

echo "Finished!"

# ...dalsza obróbka binarnych źródeł
# cd sources
# ./build.sh
# cd ..
# rm -rf sources

exit 0

# marker odcięcia
__SOURCE__
