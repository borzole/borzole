#!/bin/bash

# by jedral.one.pl
# wymaga rpm i cpio
rpm2cpio "$1" | cpio -idmv
