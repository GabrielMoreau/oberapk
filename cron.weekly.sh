#!/bin/sh

test -x /usr/bin/oberapk && /usr/bin/oberapk upgrade weekly 2>&1 | logger -t oberapk-weekly
