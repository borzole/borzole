#!/bin/bash

# otwiera folder, w którym znajduje się aktualnie grana w audacious piosenka

FILE="$(audtool2 current-song-filename)"
nautilus --no-desktop "${FILE%/*}"
