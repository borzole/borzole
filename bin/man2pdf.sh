#!/bin/bash


man -t ${@} | ps2pdf - ${@}.pdf
