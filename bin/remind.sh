#!/bin/bash

# przypomnij za chwilę
# 	$ remind.sh 2 "Jakieś powiadomienie"

echo task.sh "$2" | at now + ${1:-5} minutes
