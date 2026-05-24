#!/bin/sh
# Default Xsession

# Force Plymouth to exit since nodm doesn't do it automatically
if command -v plymouth >/dev/null 2>&1; then
    plymouth quit || true
fi

# Ensure openbox starts
exec openbox-session
