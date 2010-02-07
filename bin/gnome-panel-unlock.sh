#!/bin/bash

# odblokowanie wszystkich apletów na panelach:
gconftool-2 --all-dirs /apps/panel/objects /apps/panel/applets | xargs -I@ gconftool-2 -s @/locked -t bool false
