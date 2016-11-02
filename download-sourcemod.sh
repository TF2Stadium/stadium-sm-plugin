#!/usr/bin/env bash

LATESTSM=$(wget -o /dev/null -O - https://www.sourcemod.net/smdrop/1.8/sourcemod-latest-linux)
wget https://www.sourcemod.net/smdrop/1.8/$LATESTSM

tar xzvf $LATESTSM addons/sourcemod --strip-components=1

rm $LATESTSM
