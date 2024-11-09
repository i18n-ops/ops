#!/usr/bin/env xonsh

p"~/.xonshrc".exists() && source ~/.xonshrc

from os.path import dirname,abspath

PWD = dirname(abspath(__file__))
cd @(PWD)


