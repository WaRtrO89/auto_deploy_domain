#!/bin/bash

IFS=' ' read -r -a array <<< "$@"

source bash_completion && nvm install ${array[0]}