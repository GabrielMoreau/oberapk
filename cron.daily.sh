#!/bin/sh

test -x /usr/bin/oberapk && /usr/bin/oberapk upgrade daily 2>&1 | logger -t oberapk-daily
