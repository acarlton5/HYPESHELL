#!/bin/bash

killall quickshell
if command -v qs >/dev/null 2>&1; then
    exec qs -c hype-shell
fi

exec quickshell -c hype-shell
