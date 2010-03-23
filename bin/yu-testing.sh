#!/bin/bash

# by borzole.one.pl
sudo yum \
--enablerepo=updates-testing \
--enablerepo=rpmfusion-free-updates-testing \
--enablerepo=rpmfusion-nonfree-updates-testing \
$@
