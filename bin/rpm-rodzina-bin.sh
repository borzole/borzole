#!/bin/bash

# by jedral.one.pl
rpm -ql $(rpm -qf $(which $1)) | grep bin/

