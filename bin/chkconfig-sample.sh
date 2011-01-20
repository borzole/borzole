#!/bin/bash

# how to make service

rpm -qf --scripts `ls -1 /etc/rc.d/init.d/* | shuf -n 1`
